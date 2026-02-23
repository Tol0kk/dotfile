{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.server.matrix-conduit;
  serverDomain = config.modules.server.cloudflared.domain;
  domainConduit = "matrix.${serverDomain}";
  domainTurn = "turn.${serverDomain}";
in
{
  options.modules.server.matrix-conduit = {
    enable = mkOption {
      description = "Enable matrix-conduit services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      conduit = {
        name = "Conduit";
        icon = "services.adguardhome"; # TODO create service extractor
        info = lib.mkForce "Matric Server";
        details.listen.text = lib.mkForce domainConduit;
      };
    };

    # Traefik
    modules.server.traefik.enable = true;

    services.traefik = {
      # matrix-conduit Configuration
      dynamicConfigOptions = {
        http = {
          services.matrix-conduit.loadBalancer.servers = [
            {
              url = "http://localhost:6167";
            }
          ];

          routers.matrix-conduit = {
            entryPoints = [ "websecure" ];
            rule = "Host(`${domainConduit}`)";
            service = "matrix-conduit";
            tls.certResolver = "letsencrypt";
          };
        };
      };
    };

    # matrix-conduit Services
    services.matrix-conduit = {
      enable = true;
      settings = {
        global = {
          allow_federation = true;
          allow_registration = true;
          port = 6167;
          server_name = domainConduit;
          trusted_servers = [ "matrix.org" ];
          log = "debug";
        };
      };
    };
  };
}
