# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Garage S3 Module — Self-hosted S3-compatible object storage                 ║
# ║                                                                              ║
# ║  Architecture:                                                               ║
# ║    ┌──────────────────────────────────────────────────────────────┐          ║
# ║    │  Garage daemon                                               │          ║
# ║    │  ├── S3 API     :3900  →  Traefik  s3.domain.com             │          ║
# ║    │  ├── RPC        :3901  (inter-node, internal)                │          ║
# ║    │  ├── Web/Static :3902  →  Traefik  web.s3.domain (disable)   │          ║
# ║    │  └── Admin API  :3903  (local only)                          │          ║
# ║    └──────────────────────────────────────────────────────────────┘          ║
# ║                                                                              ║
# ║  Provides:                                                                   ║
# ║    • S3 API (path-style + vhost-style)                                       ║
# ║    • Static website hosting from buckets (disable)                           ║
# ║    • Admin API for bucket/key management                                     ║
# ║    • Traefik reverse-proxy integration with TLS                              ║
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
  cfg = config.modules.services.garage;
  traefikcfg = config.modules.services.traefik;

  s3Domain = cfg.domain;
  s3Port = cfg.ports.s3;
  rpcPort = cfg.ports.rpc;
  adminPort = cfg.ports.admin;
in
{
  options.modules.services.garage = {
    enable = mkEnableOpt "Enable Garage S3-compatible object storage";

    domain = mkOption {
      description = "Public FQDN for the S3 API endpoint";
      type = types.str;
      default = "s3.${traefikcfg.domain}";
      example = "s3.example.com";
    };

    webDomain = mkOption {
      description = "Public FQDN suffix for static website hosting (bucket websites)";
      type = types.str;
      default = "web.${cfg.domain}";
      example = "web.s3.example.com";
    };

    region = mkOption {
      description = "S3 region name (clients must target this region)";
      type = types.str;
      default = "garage";
    };

    replicationMode = mkOption {
      description = ''
        Replication mode:
          "none" / "1" = single node, no redundancy (dev/single-server)
          "2"          = 2 copies across 2 nodes
          "3"          = 3 copies across 3 nodes (production recommended)
      '';
      type = types.enum [
        "none"
        "1"
        "2"
        "3"
        "2-dangerous"
        "3-dangerous"
        "3-degraded"
      ];
      default = "none";
    };

    dataDir = mkOption {
      description = "Directory for object data blocks (use large/HDD storage)";
      type = types.str;
      default = "/var/lib/garage/data";
    };

    metaDir = mkOption {
      description = "Directory for metadata (use fast/SSD storage if possible)";
      type = types.str;
      default = "/var/lib/garage/meta";
    };

    rpcSecretFile = mkOption {
      description = ''
        Path to file containing the RPC secret (shared across all cluster nodes).
        Generate with: openssl rand -hex 32
      '';
      type = types.path;
      example = "/run/secrets/garage-rpc-secret";
    };

    adminTokenFile = mkOption {
      description = "Path to a file containing the admin API bearer token (alternative to adminToken)";
      type = types.nullOr types.path;
      default = null;
      example = "/run/secrets/garage-admin-token";
    };

    metricsToken = mkOption {
      description = "Bearer token for the /metrics prometheus endpoint (null = disabled)";
      type = types.nullOr types.str;
      default = null;
    };

    rpcPublicAddr = mkOption {
      description = "Public address:port for RPC (other nodes connect here)";
      type = types.str;
      default = "127.0.0.1:${toString rpcPort}";
      example = "10.0.0.1:3901";
    };

    # ── Port configuration ──────────────────────────────────────────────────
    ports = {
      s3 = mkOption {
        description = "Local S3 API listen port";
        type = types.port;
        default = 3900;
      };
      rpc = mkOption {
        description = "Inter-node RPC port";
        type = types.port;
        default = 3901;
      };
      web = mkOption {
        description = "Static website endpoint port";
        type = types.port;
        default = 3902;
      };
      admin = mkOption {
        description = "Admin API listen port";
        type = types.port;
        default = 3903;
      };
    };
  };

  config = mkIf cfg.enable {
    # ── Topology / service catalogue ────────────────────────────────────────
    topology.self.services = {
      garage = {
        name = "Garage S3";
        info = mkForce "S3-compatible object storage";
        details.listen.text = mkForce "${s3Domain} (localhost:${toString s3Port})";
      };
    };

    # ── Garage NixOS service ────────────────────────────────────────────────
    services.garage = {
      enable = true;
      package = pkgs.garage;

      settings = mkMerge [
        {
          # -- Core paths & replication ------------------------------------
          metadata_dir = cfg.metaDir;
          data_dir = cfg.dataDir;
          replication_mode = cfg.replicationMode;

          # -- RPC (inter-node) --------------------------------------------
          rpc_bind_addr = "[::]:${toString rpcPort}";
          rpc_public_addr = cfg.rpcPublicAddr;

          # -- S3 API ------------------------------------------------------
          s3_api = {
            s3_region = cfg.region;
            api_bind_addr = "[::]:${toString s3Port}";
            root_domain = ".${s3Domain}";
          };

          # -- Admin API ---------------------------------------------------
          admin = {
            api_bind_addr = "127.0.0.1:${toString adminPort}";
          };
        }
      ];

      # Load the RPC secret from a file (never stored in /nix/store)
      # Garage reads GARAGE_RPC_SECRET from env when environmentFile is set.
      environmentFile = cfg.rpcSecretFile;
    };

    systemd.services.garage = {
      serviceConfig = {
        # Load admin token from file if specified
        LoadCredential = [ ] ++ optional (cfg.adminTokenFile != null) "admin-token:${cfg.adminTokenFile}";
      };

      # Ensure data/meta dirs exist
      preStart = ''
        mkdir -p ${cfg.metaDir} ${cfg.dataDir}
      '';
    };

    # ── Firewall ────────────────────────────────────────────────────────────
    networking.firewall.allowedTCPPorts = [
      s3Port
      rpcPort
    ];

    # ── Traefik dynamic config ──────────────────────────────────────────────
    services.traefik.dynamicConfigOptions = {
      http = {
        # -- Services -----------------------------------------------------
        services.garage-s3.loadBalancer.servers = [
          { url = "http://localhost:${toString s3Port}"; }
        ];

        # -- Routers ------------------------------------------------------
        routers.garage-s3 = {
          entryPoints = [ "websecure" ];
          rule = "Host(`${s3Domain}`) || HostRegexp(`{subdomain:[a-z0-9-]+}.${s3Domain}`)";
          service = "garage-s3";
          tls = traefikcfg.tlsConfig;
        };
      };
    };
  };
}
