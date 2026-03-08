{
  flake.nixosModules.ollama =
    {
      pkgs-stable,
      lib,
      config,
      pkgs,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    let
      pref = config.preferences;
      cfg = config.modules.services.ollama;

      public = {
        web = "ollama-web.${pref.topDomain}";
        ollama = "ollama.${pref.topDomain}";
      };
      local = {
        web = "ollama-web.local.${pref.topDomain}";
        ollama = "ollama.local.${pref.topDomain}";
      };
      ports = {
        web = 11111;
        ollama = 11434;
      };
    in
    {
      options.modules.services.ollama = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          open-webui = {
            name = mkForce "Ollama Web UI";
            info = mkForce "Web interface for ollama";
            details = {
              Local.text = mkForce "${local.web} (localhost:${toString ports.web})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public.web}";
            };
          };
          ollama = {
            name = "Ollama";
            info = mkForce "API for ollama";
            details = {
              Local.text = mkForce "${local.ollama} (localhost:${toString ports.ollama})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public.ollama}";
            };
          };
        };

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions.http = {
          routers = {
            open-webui = {
              rule = "Host(`${local.web}`) ${if cfg.public then "|| Host(`${public.web}`" else ""})";
              entryPoints = [ "websecure" ]; # TODO use auth OICD if public
              service = "open-webui";
              tls.certResolver = "letsencrypt";
            };

            ollama = {
              rule = "Host(`${local.ollama}`) ${if cfg.public then "|| Host(`${public.ollama}`" else ""})";
              entryPoints = [ "websecure" ];
              service = "ollama";
              tls.certResolver = "letsencrypt";
            };
          };

          services = {
            open-webui.loadBalancer.servers = [
              { url = "http://127.0.0.1:${toString ports.web}"; }
            ];

            ollama.loadBalancer.servers = [
              { url = "http://127.0.0.1:${toString ports.ollama}"; }
            ];
          };
        };

        # ── Ollama Web UI ────────────────────────────────────────
        services.open-webui = {
          enable = true;
          port = ports.web;
          environment = {
            OLLAMA_BASE_URL = "http://127.0.0.1:${toString ports.ollama}";
            DO_NOT_TRACK = "True";
            SCARF_NO_ANALYTICS = "True";
            GLOBAL_LOG_LEVEL = "DEBUG";
            ENABLE_PERSISTENT_CONFIG = "False";
          };
          environmentFile = config.sops.secrets."ollama/webui".path;
        };

        # ── Ollama API ────────────────────────────────────────
        services.ollama = {
          enable = true;
          port = ports.ollama;
          package = if config.hardware.nvidia.enabled then pkgs.ollama-vulkan else pkgs.ollama-cpu;
          loadModels = [ "llama3.2:3b" ];
        };
      };
    };
}
