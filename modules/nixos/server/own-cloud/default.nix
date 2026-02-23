{
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib;
let
  cfg = config.modules.server.own-cloud;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "cloud.${serverDomain}";
in
{
  options.modules.server.own-cloud = {
    enable = mkOption {
      description = "Enable OwnCloud Infinite Scale service";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      ocis = {
        name = "Own Cloud Infinit Scale";
        icon = "services.adguardhome"; # TODO create service extractor
        info = lib.mkForce "Cloud Storage";
        details.listen.text = lib.mkForce domain;
      };
    };

    # Traefik
    modules.server.traefik.enable = true;

    services.traefik = {
      # OwnCloud Infinite Scale Configuration
      dynamicConfigOptions = {
        http = {
          services.ocis.loadBalancer.servers = [
            {
              url = "http://localhost:9200";
            }
          ];

          routers.ocis = {
            entryPoints = [ "websecure" ];
            rule = "Host(`${domain}`)";
            service = "ocis";
            tls.certResolver = "letsencrypt";
          };
        };
      };
    };

    # Secrets
    sops.secrets.secrets_env_file = {
      owner = config.services.ocis.user;
      sopsFile = ./secrets.yaml;
    };

    # OwnCloud Infinite Scale
    services.ocis = {
      enable = true;
      package = pkgs-unstable.ocis_5-bin;
      url = "https://${domain}";
      environment = {
        LOG_LEVEL = "error";
        PROXY_TLS = "false";
        OCIS_INSECURE = "true";
        PROXY_OIDC_INSECURE = "true";
        IDM_CREATE_DEMO_USERS = "true";
        PROXY_ENABLE_BASIC_AUTH = "true";
      };
      environmentFile = config.sops.secrets.secrets_env_file.path;
    };
  };
}
