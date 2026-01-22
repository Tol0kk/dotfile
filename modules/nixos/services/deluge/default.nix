{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.deluge;
  traefikcfg = config.modules.services.traefik;
in
{
  options.modules.services.deluge = {
    enable = mkOption {
      description = "Enable Deluge torrent services";
      type = types.bool;
      default = false;
    };
    web.port = mkOption {
      description = "Port for Jellyfin web interface";
      type = types.enum [ 8112 ];
      default = 8112;
    };
    authFileSecretsPath = mkOption {
      description = ''
        Enable Deluge torrent services secrets

        sops.secrets.delugeAuthFile = {
          owner = config.services.deluge.user;
          group = config.services.deluge.group;
          mode = "0600";
          sopsFile = ./secrets.yaml;
        };
      '';
      type = types.path;
      example = "/run/keys/deluge-auth";
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      deluge = {
        name = "Deluge";
        icon = "services.adguardhome";
        info = lib.mkForce "Torrent Server";
        details.listen.text = lib.mkForce "deluge.${traefikcfg.domain}(localhost:${toString cfg.web.port})";
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services.deluge.loadBalancer.servers = [
            {
              url = "http://localhost:${toString cfg.web.port}";
            }
          ];
          routers.deluge = {
            entryPoints = [ "websecure" ];
            rule = "Host(`deluge.${traefikcfg.domain}`)";
            service = "Deluge";
            tls = traefikcfg.tlsConfig;
          };
        };
      };
    };

    # Deluge
    services.deluge = {
      enable = true;
      web.enable = true;
      declarative = true;
      web.port = cfg.web.port;
      authFile = cfg.authFileSecretsPath;
      config = {
        download_location = "/data/torrents/";
        allow_remote = true;
      };
    };
  };
}
