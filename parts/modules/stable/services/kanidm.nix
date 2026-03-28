# TODO: create kanidm services
{
  flake.nixosModules.kanidm-server =
    # ╔══════════════════════════════════════════════════════════════════════════════╗
    # ║  Kanidm Module — Identity & Access Management (OIDC / OAuth2 / LDAP)         ║
    # ║                                                                              ║
    # ║  Architecture:                                                               ║
    # ║    ┌──────────────────────────────────────────────────────────────────┐      ║
    # ║    │  Kanidm daemon                                                   │      ║
    # ║    │  ├── Web UI + API   :8443  →  Traefik  auth.domain.com           │      ║
    # ║    │  ├── LDAPS          :636   (optional, direct)                    │      ║
    # ║    │  └── OIDC / OAuth2  (via web, /oauth2/openid/*)                  │      ║
    # ║    └──────────────────────────────────────────────────────────────────┘      ║
    # ║                                                                              ║
    # ║  Provides:                                                                   ║
    # ║    • Functional Kanidm instance with backup                                  ║
    # ║    • Optional LDAPS endpoint                                                 ║
    # ║    • Traefik reverse-proxy integration with traefik certs                    ║
    # ║    • Client CLI configuration for local management                           ║
    # ╚══════════════════════════════════════════════════════════════════════════════╝
    {
      libCustom,
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
        mkMerge
        mkIf
        optional
        ;
      pref = config.preferences;
      cfg = config.modules.services.kanidm;
    in
    {
      options.modules.services.kanidm = {
        domain = mkOption {
          description = "Public FQDN for Kanidm";
          type = types.str;
          default = "auth.${pref.topDomain}";
        };

        port = mkOption {
          description = "Local HTTPS listen port for the Kanidm server";
          type = types.port;
          default = 8443;
        };

        bindAddress = mkOption {
          description = "Bind address for the Kanidm server";
          type = types.str;
          default = "127.0.0.1";
        };

        # ── LDAP (optional) ────────────────────────────────────────────────────
        enableLdap = mkOption {
          description = "Enable the read-only LDAPS endpoint";
          type = types.bool;
          default = false;
        };

        ldapPort = mkOption {
          description = "LDAPS listen port (requires TLS certs)";
          type = types.port;
          default = 636;
        };

        # ── Backup ──────────────────────────────────────────────────────────────
        backupPath = mkOption {
          description = "Directory for automated database backups";
          type = types.str;
          default = "/var/backup/kanidm";
        };

        backupSchedule = mkOption {
          description = "Cron schedule for automated backups (UTC)";
          type = types.str;
          default = "0 2 * * *";
        };

        backupVersions = mkOption {
          description = "Number of backup versions to retain";
          type = types.int;
          default = 3;
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          kanidm = {
            name = "Kanidm";
            info = mkForce "Identity & Access Management";
            details =
              mkForce {
                Public.text = mkForce "${cfg.domain} (localhost:${toString cfg.port})";
              }
              // lib.optionalAttrs cfg.enableLdap {
                LDAP.text = mkForce "${cfg.domain} (localhost:${toString cfg.ldapPort})";
              };
          };
        };

        # ── Traefik dynamic config ──────────────────────────────────────────────
        services.traefik.dynamicConfigOptions.http = {
          services.kanidm.loadBalancer = {
            servers = [
              { url = "https://127.0.0.1:${toString cfg.port}"; }
            ];
            # Kanidm uses a self-signed cert internally; Traefik must not reject it
            serversTransport = "insecureTransport";

            healthCheck = {
              path = "/status";
              interval = "10s";
              timeout = "3s";
            };
          };
          serversTransports.insecureTransport = {
            insecureSkipVerify = true;
          };
          routers.kanidm = {
            entryPoints = [ "websecure" ];
            rule = "Host(`${cfg.domain}`)";
            service = "kanidm";
            tls.certResolver = "letsencrypt";
          };
        };

        # ── Backup directory ────────────────────────────────────────────────────
        systemd.tmpfiles.rules = [
          "d ${cfg.backupPath} 0750 kanidm kanidm -"
        ];

        # ── Kanidm server ──────────────────────────────────────────────────────
        services.kanidm = {
          package = pkgs.kanidm_1_9;
          enableServer = true;
          enableClient = true;
          clientSettings = {
            uri = "https://${cfg.domain}";
          };
          serverSettings = mkMerge [
            {
              domain = cfg.domain;
              origin = "https://${cfg.domain}";
              bindaddress = "${cfg.bindAddress}:${toString cfg.port}";
              tls_chain = "/var/lib/kanidm-certs/dummy-cert.pem";
              tls_key = "/var/lib/kanidm-certs/dummy-key.pem";

              online_backup = {
                path = "${cfg.backupPath}/";
                schedule = cfg.backupSchedule;
                versions = cfg.backupVersions;
              };
            }

            # {
            #   # Enable Traefik
            #   http_client_address_info = {
            #     "x-forward-for" = [
            #       "127.0.0.1"
            #       "::1"
            #     ];
            #   };
            # }
            (mkIf cfg.enableLdap {
              ldapbindaddress = "0.0.0.0:${toString cfg.ldapPort}";
            })
          ];
        };

        # ── Firewall ────────────────────────────────────────────────────────────
        networking.firewall.allowedTCPPorts = optional cfg.enableLdap cfg.ldapPort;

        # ── Dummy Certificates Service ──────────────────────────────────────────
        systemd.services.kanidm-certs = {
          description = "Generate dummy certificates for Kanidm internal TLS";
          before = [ "kanidm.service" ];
          wantedBy = [ "kanidm.service" ];

          serviceConfig = {
            Type = "oneshot";
            # This automatically creates /var/lib/kanidm-certs with secure permissions
            StateDirectory = "kanidm-certs";
          };

          script = ''
            cd /var/lib/kanidm-certs
            if [ ! -f dummy-cert.pem ]; then
              ${pkgs.openssl}/bin/openssl req -x509 -newkey rsa:4096 \
                -keyout dummy-key.pem -out dummy-cert.pem \
                -sha256 -days 3650 -nodes -subj "/CN=kanidm.internal"

              chmod 600 dummy-key.pem dummy-cert.pem

              # The kanidm user is created by NixOS during activation,
              # so it is safe to chown to it here.
              chown kanidm:kanidm dummy-key.pem dummy-cert.pem
            fi
          '';
        };
      };
    };

  flake.nixosModules.kanidm-client = {
    config =
      {
        lib,
        config,
        pkgs,
        ...
      }:
      {

        services.kanidm = {
          package = pkgs.kanidm_1_9;
          enableClient = true;
          clientSettings = {
            # uri = "https://${cfg.domain}";
            verify_host = true;
            verify_trust = true;
          };
          enablePam = true;
        };
      };
  };
}
