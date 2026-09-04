{
  flake.nixosModules.forgejo =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib)
        types
        mkOption
        mkForce
        mkIf
        optionalAttrs
        ;
      pref = config.preferences;
      cfg = config.modules.services.forgejo;

      public = {
        web = "git.${pref.topDomain}";
      };
      local = {
        web = "git.local.${pref.topDomain}";
      };
      ports = {
        web = 3000;
        ssh = 22; # Forgejo internal SSH server
      };

      kanidmUrl = if pref.sso == null then "https://auth.${pref.topDomain}" else "https://${pref.sso}";
      ssoClientId = "forgejo";

      ssoName = "kanidm";
      # Kanidm's OIDC well-known discovery endpoint for this client.
      ssoDiscoveryUrl = "${kanidmUrl}/oauth2/openid/${ssoClientId}/.well-known/openid-configuration";
      # 'openid' is implicitly added by Forgejo, no need to repeat it.
      ssoScopes = "email profile";
      # Kanidm uses a simple SVG badge — skip the icon-url, Forgejo will use a default.
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.forgejo = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
          description = "Whether to expose Forgejo publicly";
        };

        sso = mkOption {
          default = true;
          type = types.bool;
          description = "Whether to enable Kanidm OIDC single sign-on";
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services.forgejo = {
          name = "Forgejo";
          info = mkForce "Self-hosted Git forge";
          details = mkForce (
            {
              Local.text = mkForce "${local.web} (localhost:${toString ports.web})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public.web}";
            }
          );
        };

        # ── Glance Services ─────────────────────────────────────────────────────
        modules.services.glance.server_service = [
          {
            title = "Forgejo";
            url = if cfg.public then "https://${public.web}" else "https://${local.web}";
            check-url = "https://${local.web}/api/healthz";
            icon = "si:forgejo";
          }
        ];

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions.http = {
          routers.forgejo = {
            rule = "Host(`${local.web}`) ${if cfg.public then "|| Host(`${public.web}`)" else ""}";
            entryPoints = [ "websecure" ];
            service = "forgejo";
            tls.certResolver = "letsencrypt";
          };

          services.forgejo.loadBalancer = {
            servers = [
              { url = "http://127.0.0.1:${toString ports.web}"; }
            ];
            healthCheck = {
              path = "/api/healthz";
              interval = "10s";
              timeout = "3s";
            };
          };
        };

        # ── Forgejo Configuration ────────────────────────────────────────
        services.forgejo = {
          enable = true;

          database.type = "sqlite3";

          settings = {
            server = {
              HTTP_PORT = ports.web;
              HTTP_ADDR = "127.0.0.1";

              # Domain settings for clone URLs
              DOMAIN = if cfg.public then public.web else local.web;
              ROOT_URL = "https://${if cfg.public then public.web else local.web}/";

              # SSH Configuration
              START_SSH_SERVER = true;
              SSH_PORT = ports.ssh;
              SSH_LISTEN_PORT = ports.ssh;
              SSH_DOMAIN = if cfg.public then public.web else local.web;
            };

            service = {
              # With SSO enabled we allow account creation *only* via the
              # external provider (no self-service local signup). Note that
              # DISABLE_REGISTRATION = true would also block OIDC
              # auto-registration, so it must be false here.
              DISABLE_REGISTRATION = !cfg.sso;
              ALLOW_ONLY_EXTERNAL_REGISTRATION = cfg.sso;
              SHOW_REGISTRATION_BUTTON = false;
            };

            session = {
              COOKIE_SECURE = true;
            };
          }
          // optionalAttrs cfg.sso {
            oauth2_client = {
              # Create local accounts automatically for new OIDC users.
              ENABLE_AUTO_REGISTRATION = true;
              # Link to an existing account when the email/username matches
              # (lets the declarative admin below sign in via Kanidm).
              # Security note: only safe because Kanidm is the sole trusted IdP.
              ACCOUNT_LINKING = "auto";
              # Source of the username for new accounts.
              # 'nickname' uses the OIDC nickname claim
              # (falls back to preferred_username for OpenID Connect providers).
              USERNAME = "nickname";
              OPENID_CONNECT_SCOPES = ssoScopes;
              UPDATE_AVATAR = true;
            };
          };
        };

        # ── Firewall Rules ────────────────────────────────────────
        networking.firewall = {
          allowedTCPPorts = [ ports.ssh ];
        };

        # ── SOPS Secrets ────────────────────────────────────────
        sops.secrets."forgejo/admin-env" = {
          owner = "forgejo";
          group = "forgejo";
          mode = "0400";
        };

        # Env file must define: FORGEJO_OIDC_CLIENT_SECRET=<kanidm basic secret>
        sops.secrets."forgejo/oidc-env" = mkIf cfg.sso {
          owner = "forgejo";
          group = "forgejo";
          mode = "0400";
        };

        # ── Declarative Admin Setup ────────────────────────────────────────
        systemd.services.forgejo-admin-setup = {
          description = "Create Forgejo Admin User";
          environment = lib.filterAttrs (
            n: _: lib.hasPrefix "GITEA_" n
          ) config.systemd.services.forgejo.environment;
          requires = [ "forgejo.service" ];
          after = [ "forgejo.service" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            User = config.systemd.services.forgejo.serviceConfig.User;
            Group = config.systemd.services.forgejo.serviceConfig.Group;
            WorkingDirectory = config.systemd.services.forgejo.serviceConfig.WorkingDirectory;
            EnvironmentFile = [ config.sops.secrets."forgejo/admin-env".path ];
          };

          script = ''
            ${pkgs.forgejo}/bin/forgejo admin user create \
              --admin \
              --username "$FORGEJO_ADMIN_USERNAME" \
              --password "$FORGEJO_ADMIN_PASSWORD" \
              --email "$FORGEJO_ADMIN_EMAIL" \
              --must-change-password=false || true
          '';
        };

        # ── Declarative SSO (Kanidm OIDC) Setup ────────────────────────────
        # OAuth2 auth sources live in the DB, not app.ini, so they are
        # registered via the CLI. This is made idempotent by looking up the
        # existing source by name and updating it, or adding it if absent.
        systemd.services.forgejo-sso-setup = mkIf cfg.sso {
          description = "Configure Forgejo Kanidm OIDC authentication source";
          environment = {
            USER = config.services.forgejo.user;
            HOME = config.services.forgejo.stateDir;
            GITEA_WORK_DIR = config.services.forgejo.stateDir;
            GITEA_CUSTOM = config.services.forgejo.customDir;
          };
          path = [ pkgs.gawk ];
          requires = [ "forgejo.service" ];
          after = [
            "forgejo.service"
            "forgejo-admin-setup.service"
          ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            User = config.systemd.services.forgejo.serviceConfig.User;
            Group = config.systemd.services.forgejo.serviceConfig.Group;
            WorkingDirectory = config.systemd.services.forgejo.serviceConfig.WorkingDirectory;
            EnvironmentFile = [ config.sops.secrets."forgejo/oidc-env".path ];
          };

          script = ''
            set -euo pipefail

            forgejo="${pkgs.forgejo}/bin/forgejo"

            # Grab the auth-source table once. Tolerate a non-zero exit / empty
            # table (e.g. no sources yet) instead of letting pipefail + set -e
            # abort here, and let any real error reach the journal.
            auth_list="$("$forgejo" admin auth list)"

            # Parse from a here-string: awk is the only command in the
            # substitution, so its early `exit` can't SIGPIPE an upstream
            # process and trip pipefail.
            existing_id="$(awk -v n="${ssoName}" \
              'NR > 1 && $2 == n { print $1; exit }' <<< "$auth_list")"

            if [ -n "$existing_id" ]; then
              "$forgejo" admin auth update-oauth \
                --id "$existing_id" \
                --provider openidConnect \
                --name "${ssoName}" \
                --key "${ssoClientId}" \
                --secret "$FORGEJO_OIDC_CLIENT_SECRET" \
                --auto-discover-url "${ssoDiscoveryUrl}" \
                --scopes "${ssoScopes}"
            else
              "$forgejo" admin auth add-oauth \
                --provider openidConnect \
                --name "${ssoName}" \
                --key "${ssoClientId}" \
                --secret "$FORGEJO_OIDC_CLIENT_SECRET" \
                --auto-discover-url "${ssoDiscoveryUrl}" \
                --scopes "${ssoScopes}"
            fi
          '';
        };
      };
    };
}
