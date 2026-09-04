{
  flake.nixosModules.vaultwarden =
    {
      lib,
      config,
      libCustom,
      pkgs-unstable,
      ...
    }:
    let
      inherit (lib)
        types
        mkOption
        mkForce
        ;
      pref = config.preferences;
      cfg = config.modules.services.glance;

      local = "vaultwarden.local.${pref.topDomain}";
      public = "vaultwarden.${pref.topDomain}";
      port = 8222;

      kanidmUrl = if pref.sso == null then "https://auth.${pref.topDomain}" else "https://${pref.sso}";
      ssoClientId = "vaultwarden";
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.vaultwarden = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          vaultwarden = {
            info = lib.mkForce "Self hosted password manager";
            details = {
              Local.text = mkForce "${local} (localhost:${toString port})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public}";
            };
          };
        };

        # ── Glance Services ─────────────────────────────────────────────────────
        modules.services.glance.server_service = [
          {
            title = "Vaultwarden";
            url = if cfg.public then "https://${public}" else "https://${local}";
            check-url = "https://${local}/api/alive";
            icon = "si:vaultwarden";
          }
        ];

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions = {
          http = {
            services.vaultwarden.loadBalancer.servers = [
              { url = "http://127.0.0.1:${toString port}"; }
            ];
            routers.vaultwarden = {
              rule = if cfg.public then "Host(`${local}`) || Host(`${public}`)" else "Host(`${local}`)";
              priority = 10;
              entryPoints = [ "websecure" ];
              service = "vaultwarden";
              tls.certResolver = "letsencrypt";
            };
          };
        };

        # ── Secrets Declaration ────────────────────────────────────────
        # This can hold an enviroment file with the following field
        # - ADMIN_TOKEN=<random-token>
        # - SMTP_PASSWORD=<smtp-password>
        # - SSO_CLIENT_SECRET=<kanidm-basic-secret>
        sops.secrets."vaultwarden/env.secrets" = { };

        # ── Vaultwaredn config ────────────────────────────────────────
        services.vaultwarden = {
          enable = true;
          webVaultPackage = pkgs-unstable.pkgsCross.aarch64-multiplatform.vaultwarden.webvault;
          package = pkgs-unstable.pkgsCross.aarch64-multiplatform.vaultwarden;
          backupDir = "/var/local/vaultwarden/backup";
          environmentFile = config.sops.secrets."vaultwarden/env.secrets".path;
          config = {
            DOMAIN = if cfg.public then "https://${public}" else "https://${local}";
            ROCKET_PORT = port;
            WEB_VAULT_ENABLED = true;
            SIGNUPS_ALLOWED = false;

            SSO_ENABLED = true;
            SSO_AUTHORITY = "${kanidmUrl}/oauth2/openid/${ssoClientId}";
            SSO_CLIENT_ID = ssoClientId;
            SSO_AUTH_ONLY_NOT_SESSION = true;
            SSO_SCOPES = "openid email profile";
            SSO_PKCE = true;
            SSO_ONLY = true;
          };
        };
      };
    };
}
