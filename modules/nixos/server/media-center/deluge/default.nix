{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.server.media-center.deluge;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "deluge.cloud.${serverDomain}";
in
{
  options.modules.server.media-center.deluge = {
    enable = mkOption {
      description = "Enable Deluge torrent services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      deluge = {
        name = "Deluge";
        icon = "services.adguardhome"; # TODO create service extractor
        info = lib.mkForce "Torrent Server";
        details.listen.text = lib.mkForce domain;
      };
    };

    modules.server.traefik.enable = true;

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services.deluge.loadBalancer.servers = [
            {
              url = "http://localhost:8112";
            }
          ];
          routers.deluge = {
            entryPoints = [ "websecure" ];
            rule = "Host(`${domain}`)";
            service = "deluge";
            tls.certResolver = "letsencrypt";
          };
        };
      };
    };

    sops.secrets.delugeAuthFile = {
      owner = config.services.deluge.user;
      group = config.services.deluge.group;
      mode = "0600";
      sopsFile = ./secrets.yaml;
    };

    # Deluge
    services.deluge = {
      enable = true;
      web.enable = true;
      declarative = true;
      authFile = config.sops.secrets.delugeAuthFile.path;
      config = {
        download_location = "/data/torrents/";
        # max_upload_speed = "1000.0";
        # share_ratio_limit = "2.0";
        allow_remote = true;
      };
    };
  };
}
