{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.media-center;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "cloud.${serverDomain}";
in {
  options.modules.server.media-center = {
    enable = mkOption {
      description = "Enable Media service (Radarr, Lidarr, Sonarr, Jellyfin)";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      services.radarr.enable = true;
      # services.sonarr.enable = true;
      services.lidarr.enable = true;
      services.jellyfin.enable = true;
    };
}
