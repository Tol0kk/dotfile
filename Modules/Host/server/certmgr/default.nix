{
  lib,
  pkgs,
  config,
}:
with lib; let
  cfg = config.modules.server.kanidm;
  _serverDomain = config.modules.server.cloudflared.domain;
  _tunnelId = config.modules.server.cloudflared.tunnelId;
  _domain = "uptime.${serverDomain}";
in {
  options.modules.server.uptime-kuma = {
    enable = mkOption {
      description = "Enable Uptime Kuma service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      services.uptime-kuma = {
        enable = true;
        settings = {
          PORT = "4000";
        };
      };
    };
}
