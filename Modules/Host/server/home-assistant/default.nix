{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.home-assistant;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
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
        ];
        config = {
          # Includes dependencies for a basic setup
          # https://www.home-assistant.io/integrations/default_config/
          default_config = {};
          "scene ui" = "!include scenes.yaml";
        };
      };
    };
}
