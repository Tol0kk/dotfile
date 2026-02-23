{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.jellyfin;
  traefikcfg = config.modules.services.traefik;
in
{
  options.modules.services.jellyfin = {
    enable = mkOption {
      description = "Enable Jellyfin service";
      type = types.bool;
      default = false;
    };
    port = mkOption {
      description = "Port for Jellyfin web interface";
      type = types.enum [ 8096 ];
      default = 8096;
    };
    openFirewall = mkOption {
      description = "Open port in the firewall for Jellyfin (8096)";
      type = types.bool;
      default = false;
    };
    domain = mkOption {
      type = types.str;
      default = "media.${traefikcfg.domain}";
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      jellyfin = {
        name = "Jellyfin";
        info = lib.mkForce "Media Server";
        details.listen.text = lib.mkForce "${cfg.domain}(localhost:${toString cfg.port})";
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services.jellyfin.loadBalancer.servers = [
            {
              url = "http://localhost:${toString cfg.port}";
            }
          ];
          routers.jellyfin = {
            entryPoints = [ "websecure" ];
            rule = "Host(`${cfg.domain}`)";
            service = "jellyfin";
            tls = traefikcfg.tlsConfig;
          };
        };
      };
    };

    # Jellyfin
    services.jellyfin = {
      enable = true;
      openFirewall = cfg.openFirewall;
    };
    environment.systemPackages = [
      pkgs.jellyfin
      pkgs.jellyfin-web
      (pkgs.jellyfin-ffmpeg.override {
        # Exact version of ffmpeg_* depends on what jellyfin-ffmpeg package is using.
        # In 24.11 it's ffmpeg_7-full.
        # See jellyfin-ffmpeg package source for details
        # ffmpeg_7-full = pkgs.rkffmpeg;
      })
      # pkgs.rkmpp
    ];
  };
}
