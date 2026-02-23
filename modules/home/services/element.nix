{
  lib,
  pkgs,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.services.element;
in
{
  options.modules.services.element = {
    enable = mkEnableOpt "Enable Element";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      element-desktop
      (makeAutostartItem {
        name = "element-desktop";
        package = element-desktop;
        prependExtraArgs = [ "--start-in-tray" ];
      })
    ];
  };
}
