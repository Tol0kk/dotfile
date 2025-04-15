{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.media-center;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "cloud.${serverDomain}";
in {
  options.modules.server.media-center = {
    enable = mkOption {
      description = "Enable Media service (Radarr, Lidarr, Sonarr, Jellyfin)";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      # services.radarr.enable = true;
      # services.sonarr.enable = true;
      # services.lidarr.enable = true;


      modules.server.traefik.enable = true;
      services.traefik = {
        # OwnCloud Infinite Scale Configuration
        dynamicConfigOptions = {
          http = {
            services.jellyfin.loadBalancer.servers = [
              {
                url = "http://localhost:8096";
              }
            ];

            routers.jellyfin = {
              entryPoints = ["websecure"];
              rule = "Host(`media.${domain}`)";
              service = "jellyfin";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };

      services.jellyfin = {
        enable = true;
        # openFirewall = true;
      };
      environment.systemPackages = [
        pkgs.jellyfin
        pkgs.jellyfin-web
        pkgs.jellyfin-ffmpeg
      ];
    };
}
