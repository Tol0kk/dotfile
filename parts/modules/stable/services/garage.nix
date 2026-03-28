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
{ self, ... }:
{
  flake.nixosModules.garage =
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
        optional
        ;
      pref = config.preferences;
      cfg = config.modules.services.garage;

      public = {
        s3 = "s3.${pref.topDomain}";
      };

      local = {
        s3 = "s3.local.${pref.topDomain}";
      };
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.garage = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
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

        metricsToken = mkOption {
          description = "Bearer token for the /metrics prometheus endpoint (null = disabled)";
          type = types.nullOr types.str;
          default = null;
        };

        # ADDED: rpcPublicAddr because it was called in settings but missing here
        rpcPublicAddr = mkOption {
          description = "Public IP or hostname (with port) for inter-node RPC communication";
          type = types.str;
          default = "127.0.0.1:3901"; # Sane default for a single-node setup
        };

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
          admin = mkOption {
            description = "Admin API listen port";
            type = types.port;
            default = 3903;
          };
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          garage = {
            icon = "${self}/assets/icons/garage.svg";
            name = "Garage S3";
            info = mkForce "S3-compatible object storage";
            details = {
              Local.text = mkForce "${local.s3} (localhost:${toString cfg.ports.s3})";
              Admin.text = mkForce "(localhost:${toString cfg.ports.admin})";
              RPC.text = mkForce "(localhost:${toString cfg.ports.rpc})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public.s3}";
            };
          };
        };

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions = {
          http = {
            services = {
              garage-s3.loadBalancer = {
                servers = [
                  { url = "http://localhost:${toString cfg.ports.s3}"; }
                ];
                healthCheck = {
                  path = "/health";
                  interval = "10s";
                  timeout = "3s";
                };
              };
            };

            routers.garage-s3 = {
              entryPoints = [ "websecure" ];
              # FIXED: String interpolation syntax
              rule = "Host(`${local.s3}`) ${if cfg.public then "|| Host(`${public.s3}`)" else ""}";
              service = "garage-s3";
              tls.certResolver = "letsencrypt";
            };
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
              rpc_bind_addr = "[::]:${toString cfg.ports.rpc}";
              rpc_public_addr = cfg.rpcPublicAddr;

              # -- S3 API ------------------------------------------------------
              s3_api = {
                s3_region = cfg.region;
                api_bind_addr = "[::]:${toString cfg.ports.s3}";
                root_domain = ".${if cfg.public then public.s3 else local.s3}";
              };

              # -- Admin API ---------------------------------------------------
              admin = {
                api_bind_addr = "127.0.0.1:${toString cfg.ports.admin}";
              };
            }
          ];

          # Load the RPC secret from a file (never stored in /nix/store)
          # Garage reads GARAGE_RPC_SECRET from env when environmentFile is set.
          environmentFile = config.sops.secrets."garage/rpc".path;
        };

        systemd.services.garage = {
          serviceConfig = {
            # Load admin token from file if specified
            LoadCredential =
              [ ]
              ++
                optional (config.sops.secrets."garage/admin".path != null)
                  "admin-token:${config.sops.secrets."garage/admin".path}";
          };

          # Ensure data/meta dirs exist
          preStart = ''
            mkdir -p ${cfg.metaDir} ${cfg.dataDir}
          '';
        };

        # ── SOPS Secrets ────────────────────────────────────────────────────────
        # ADDED: Must be defined so `.path` can be resolved by Nix safely.
        sops.secrets."garage/rpc" = { };
        sops.secrets."garage/admin" = { };

        # ── Firewall ────────────────────────────────────────────────────────────
        networking.firewall.allowedTCPPorts = [
          cfg.ports.rpc
        ];
      };
    };
}
