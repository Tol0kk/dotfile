{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.own-cloud;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "cloud.${serverDomain}";
in {
  options.modules.server.own-cloud = {
    enable = mkOption {
      description = "Enable OwnCloud Infinite Scale service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      # TODO See https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=+ocis
      services.ocis.enable = true;
    };
}
