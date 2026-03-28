# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  SearXNG Module — Privacy-respecting, hackable metasearch engine             ║
# ║                                                                              ║
# ║  Architecture:                                                               ║
# ║    ┌──────────────────────────────────────────────────────────────┐          ║
# ║    │  SearXNG daemon                                              │          ║
# ║    │  └── HTTP UI/API  :8080  →  Traefik  search.domain.com       │          ║
# ║    └──────────────────────────────────────────────────────────────┘          ║
# ║                                                                              ║
# ║  Provides:                                                                   ║
# ║    • Web Search Interface                                                    ║
# ║    • Search API (JSON/CSV/RSS)                                               ║
# ║    • Traefik reverse-proxy integration with TLS                              ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
{
  flake.nixosModules.searxng =
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
        ;
      pref = config.preferences;
      cfg = config.modules.services.searxng;

      public = {
        search = "search.${pref.topDomain}";
      };

      local = {
        search = "search.local.${pref.topDomain}";
      };
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.searxng = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };

        port = mkOption {
          description = "Local SearXNG HTTP listen port";
          type = types.port;
          default = 8570;
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          searxng = {
            name = "SearXNG";
            info = mkForce "Privacy-respecting metasearch engine";
            details = mkForce (
              {
                Local.text = mkForce "${local.search} (localhost:${toString cfg.port})";
              }
              // lib.optionalAttrs cfg.public {
                Public.text = mkForce "${public.search}";
              }
            );
          };
        };

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions = {
          http = {
            services = {
              searxng.loadBalancer = {
                servers = [
                  { url = "http://localhost:${toString cfg.port}"; }
                ];
                healthCheck = {
                  path = "/stats";
                  interval = "10s";
                  timeout = "3s";
                };
              };
            };

            routers.searxng = {
              entryPoints = [ "websecure" ];
              rule = "Host(`${local.search}`) ${if cfg.public then "|| Host(`${public.search}`)" else ""}";
              service = "searxng";
              tls.certResolver = "letsencrypt";
            };
          };
        };

        # ── SearXNG NixOS service ───────────────────────────────────────────────
        services.searx = {
          enable = true;
          package = pkgs.searxng;

          # Automatically create and manage a local Redis instance for caching/rate limiting
          redisCreateLocally = true;

          settings = {
            server = {
              port = cfg.port;
              bind_address = "0.0.0.0";
              # secret_key is intentionally omitted here to be loaded via environmentFile
              image_proxy = true;
              secret_key = "$SEARX_SECRET_KEY";
            };
            search = {
              safe_search = 1; # 0 = None, 1 = Moderate, 2 = Strict
              autocomplete = "google";
            };
            ui = {
              static_use_hash = true;
              theme_args.simple_style = "auto";
            };
          };

          # Load SEARXNG_SECRET from env file to avoid storing it in the Nix store
          environmentFile = config.sops.secrets."searxng/env".path;
        };

        # ── SOPS Secrets ────────────────────────────────────────────────────────
        # Requires a file containing: SEARXNG_SECRET="your_generated_secret_here"
        sops.secrets."searxng/env" = { };
      };
    };
}
