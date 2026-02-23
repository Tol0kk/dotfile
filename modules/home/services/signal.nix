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
  cfg = config.modules.services.signal;
in
{
  options.modules.services.signal = {
    enable = mkEnableOpt "Enable Signal";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      signal-desktop
      (makeAutostartItem {
        name = "signal";
        package = signal-desktop;
        prependExtraArgs = [ "--start-in-tray" ];
      })
    ];
  };
}
