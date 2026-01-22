{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.netbird;
  traefikcfg = config.modules.services.traefik;
in
{
  options.modules.services.netbird = {
    client = {
      enable = mkOption {
        description = "Enable Netbird client services";
        type = types.bool;
        default = false;
      };
    };
    server = {
      enable = mkOption {
        description = "Enable Netbird server services";
        type = types.bool;
        default = false;
      };
      web.port = mkOption {
        description = "Port for Jellyfin web interface";
        type = types.enum [ 8112 ];
        default = 8112;
      };
      coturnPasswordFile = mkOption {
        type = types.path;
      };
    };
  };

  config = (
    mkMerge [
      (mkIf cfg.server.enable {
        topology.self.services = {
          netbird = {
            name = "Netbird Server";
            icon = "services.adguardhome";
            info = lib.mkForce "VPN Server";
            details.listen.text = lib.mkForce "netbird.${traefikcfg.domain}(localhost:${toString cfg.server.web.port})";
          };
        };

        services.traefik = {
          dynamicConfigOptions = {
            http = {
              services.netbird.loadBalancer.servers = [
                {
                  url = "http://localhost:${toString cfg.server.web.port}";
                }
              ];
              routers.netbird = {
                entryPoints = [ "websecure" ];
                rule = "Host(`netbird.${traefikcfg.domain}`)";
                service = "Netbird";
                tls = traefikcfg.tlsConfig;
              };
            };
          };
        };

        services.netbird.enable = true;
        services.netbird.server = {
          enable = true;
          domain = "127.0.0.1";
          coturn = {
            enable = true;
            passwordFile = cfg.server.coturnPasswordFile;
            user = "netbird";
          };
          dashboard = {
            enable = false;
          };
          management = {
            enable = true;

            oidcConfigEndpoint = "https://example.eu.auth0.com/.well-known/openid-configuration";
          };
        };
        systemd.services.coturn =
          let
            preStart' = optionalString (cfg.server.coturnPasswordFile != null) "";
          in
          (optionalAttrs (preStart' != "") { preStart = mkAfter preStart'; })
          // {
            serviceConfig.LoadCredential = [ "password:${cfg.server.coturnPasswordFile}" ];
          };
      })
      (mkIf cfg.client.enable {
        environment.systemPackages = with pkgs; [
          netbird
          netbird-dashboard
          netbird-ui
        ];
        services.netbird.ui.enable = true;
        services.netbird.clients = {
          netbird = {
            port = 51820;
            hardened = false;
            interface = "nb0";
            name = "netbird";
          };
        };
      })
    ]
  );
}
