{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.apps.avizo;
in
{
  options.modules.apps.avizo = {
    enable = mkEnableOpt "Enable avizo";
  };

  # TODO
  config = mkIf cfg.enable {
    home.packages = [ pkgs.pamixer ];
    services.avizo.enable = true;
    services.avizo.settings = {
      default = {
        y-offset = 0.95;
        border-radius = 30;
        block-height = 10;
        block-spacing = 5;
        block-count = 20;
      };
    };
  };
}
