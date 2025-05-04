{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.server.media-center.jellyfin;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "media.cloud.${serverDomain}";
in {
  options.modules.server.media-center.jellyfin = {
    enable = mkOption {
      description = "Enable Jellyfin service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      topology.self.services = {
        jellyfin = {
          name = "Jellyfin";
          info = lib.mkForce "Media Server";
          details.listen.text = lib.mkForce domain;
        };
      };

      modules.server.traefik.enable = true;

      services.traefik = {
        dynamicConfigOptions = {
          http = {
            services.jellyfin.loadBalancer.servers = [
              {
                url = "http://localhost:8096";
              }
            ];
            routers.jellyfin = {
              entryPoints = ["websecure"];
              rule = "Host(`${domain}`)";
              service = "jellyfin";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };

      # Jellyfin
      services.jellyfin = {
        enable = true;
      };
      environment.systemPackages = [
        pkgs.jellyfin
        pkgs.jellyfin-web
        pkgs.jellyfin-ffmpeg
      ];
    };
}
