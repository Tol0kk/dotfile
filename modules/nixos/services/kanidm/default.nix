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
with lib;
with libCustom;
let
  cfg = config.modules.services.kanidm;
  traefikcfg = config.modules.services.traefik;
in
{
  options.modules.services.kanidm = {
    server = {

      enable = mkEnableOpt "Enable Kanidm identity management server";

      domain = mkOption {
        description = "Public FQDN for Kanidm (e.g. auth.example.com)";
        type = types.str;
        default = "auth.${traefikcfg.domain}";
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

      # ── TLS ─────────────────────────────────────────────────────────────────
      tlsCertFile = mkOption {
        description = ''
          Path to TLS certificate chain (PEM).
          Kanidm requires TLS natively — even behind a reverse proxy.
          Use ACME, self-signed, or agenix-managed certs.
        '';
        type = types.path;
        default = "/var/lib/certificates/${cfg.server.domain}/public.crt";
      };

      tlsKeyFile = mkOption {
        description = "Path to TLS private key (PEM)";
        type = types.path;
        default = "/var/lib/certificates/${cfg.server.domain}/private.key";
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

      # ── Secrets ─────────────────────────────────────────────────────────────
      adminPasswordFile = mkOption {
        description = ''
          Path to file containing the admin password.
          Do NOT use a Nix store path. Use agenix/sops-nix.
        '';
        type = types.nullOr types.path;
        default = null;
        example = "/run/secrets/kanidm-admin-password";
      };

      idmAdminPasswordFile = mkOption {
        description = "Path to file containing the idm_admin password";
        type = types.nullOr types.path;
        default = null;
        example = "/run/secrets/kanidm-idm-admin-password";
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

      # ── Reverse proxy ──────────────────────────────────────────────────────
      useTraefik = mkOption {
        description = "Configure Traefik as reverse proxy (false = bring your own)";
        type = types.bool;
        default = true;
      };
    };

    # ── Client ─────────────────────────────────────────────────────────────
    client = {
      enable = mkOption {
        description = "Enable the Kanidm CLI client on this machine";
        type = types.bool;
        default = true;
      };

      # ── Unix integration ───────────────────────────────────────────────────
      enableUnixd = mkOption {
        description = "Enable kanidm-unixd for PAM/NSS login with Kanidm accounts";
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.client.enable {
      services.kanidm = {
        enableClient = true;
        clientSettings = {
          uri = "https://${cfg.server.domain}";
        };
        enablePam = cfg.client.enableUnixd;
      };
    })
    (mkIf cfg.server.enable {
      # ── Topology / service catalogue ────────────────────────────────────────
      topology.self.services = {
        kanidm = {
          name = "Kanidm";
          info = mkForce "Identity & Access Management";
          details.listen.text = mkForce "${cfg.server.domain} (localhost:${toString cfg.port})";
        };
      };

      # ── Backup directory ────────────────────────────────────────────────────
      systemd.tmpfiles.rules = [
        "d ${cfg.server.backupPath} 0750 kanidm kanidm -"
      ];

      # ── Kanidm server ──────────────────────────────────────────────────────
      services.kanidm = {
        package = pkgs.kanidm_1_8;

        enableServer = true;
        serverSettings = mkMerge [
          {
            domain = cfg.server.domain;
            origin = "https://${cfg.server.domain}";
            bindaddress = "${cfg.server.bindAddress}:${toString cfg.server.port}";
            tls_chain = cfg.server.tlsCertFile;
            tls_key = cfg.server.tlsKeyFile;
            trust_x_forward_for = cfg.server.useTraefik;

            online_backup = {
              path = "${cfg.server.backupPath}/";
              schedule = cfg.server.backupSchedule;
              versions = cfg.server.backupVersions;
            };
          }
          (mkIf cfg.server.enableLdap {
            ldapbindaddress = "0.0.0.0:${toString cfg.server.ldapPort}";
          })
        ];
      };

      # ── Firewall ────────────────────────────────────────────────────────────
      networking.firewall.allowedTCPPorts = optional cfg.server.enableLdap cfg.ldapPort;

      # ── Traefik dynamic config ──────────────────────────────────────────────
      services.traefik.dynamicConfigOptions = mkIf cfg.server.useTraefik {
        http = {
          services.kanidm.loadBalancer.servers = [
            { url = "https://localhost:${toString cfg.server.port}"; }
          ];
          serversTransports.kanidm-transport.insecureSkipVerify = true;
          routers.kanidm = {
            entryPoints = [ "websecure" ];
            rule = "Host(`${cfg.server.domain}`)";
            service = "kanidm";
            tls = {
              certResolver = "letsencrypt"; # or whatever resolver name you're using
              domains = [
                {
                  main = cfg.server.domain;
                }
              ];
            };
          };
        };
      };
    })
  ];
}
