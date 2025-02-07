{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.home-assistant;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "ha.${serverDomain}";
in {
  options.modules.server.home-assistant = {
    enable = mkOption {
      description = "Enable Home Assistant service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      # Make sure traefik module is options
      modules.server.traefik.enable = true;

      services.traefik = {
        dynamicConfigOptions = {
          http = {
            services.home-assistant.loadBalancer.servers = [
              {
                url = "http://[::]:8123";
              }
            ];

            routers.home-assistant = {
              entryPoints = ["websecure"];
              rule = "Host(`${domain}`)";
              service = "home-assistant";
              tls.certResolver = "letsencrypt";
              # middlewares = ["oidc-auth"]; Home Assistant don't support auth middleware
            };
          };
        };
      };

      # Home Assistant
      services.home-assistant = {
        enable = true;
        extraComponents = [
          # Components required to complete the onboarding
          "esphome" # Add ESPHome integration: https://www.home-assistant.io/integrations/esphome/
          "met" #  Weather forecast: https://www.home-assistant.io/integrations/met/
          "radio_browser" # Radio automation: https://www.home-assistant.io/integrations/radio_browser/
          "tuya" # Add Tuya Powered Device Integration: https://www.home-assistant.io/integrations/tuya/
          "zha" # Add Zigbee Home Automation: https://www.home-assistant.io/integrations/zha/
          "thread" # Add Thread integration: https://www.home-assistant.io/integrations/thread/

          "google_translate" #
        ];
        config = {
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          default_config = {};
          "scene ui" = "!include scenes.yaml";
          http = {
            server_host = "::1";
            trusted_proxies = ["::1"];
            use_x_forwarded_for = true;
          };
        };
      };
    };
}
