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
        ssh = 2222; # Forgejo internal SSH server
      };
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.forgejo = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
          description = "Whether to expose Forgejo publicly";
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
              DISABLE_REGISTRATION = true;
            };

            session = {
              COOKIE_SECURE = true;
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

        # ── Declarative Admin Setup ────────────────────────────────────────
        systemd.services.forgejo-admin-setup = {
          description = "Create Forgejo Admin User";
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
      };
    };
}
