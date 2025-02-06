{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.uptime-kuma;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "uptime.${serverDomain}";
in {
  options.modules.server.uptime-kuma = {
    enable = mkOption {
      description = "Enable Uptime Kuma service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      # Uptime Kuma Service
      services.uptime-kuma = {
        enable = true;
        # see https://github.com/louislam/uptime-kuma/wiki/Environment-Variables for supported values.
        settings = {
          PORT = "8000";
        };
      };

      # Make sure traefik module is options
      modules.server.traefik.enable = true;

      services.traefik = {
        dynamicConfigOptions = {
          http = {
            services.uptime-kuma.loadBalancer.servers = [
              {
                url = "http://127.0.0.1:8000";
              }
            ];

            routers.uptime-kuma = {
              entryPoints = ["websecure"];
              rule = "Host(`${domain}`)";
              service = "uptime-kuma";
              tls.certResolver = "letsencrypt";
              middlewares = ["oidc-auth"];
            };
          };
        };
      };
    };
}
