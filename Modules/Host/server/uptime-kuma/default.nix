{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.uptime-kuma;
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
        # see https://github.com/louislam/uptime-kuma/wiki/Environment-Variables for supported values.
        settings = {
          PORT = "8000";
        };
      };
    };
}
