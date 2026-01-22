{
  pkgs,
  lib,
  assets,
  config,
  inputs,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.desktop.wayland.niri;
in {
  options.modules.desktop.wayland.niri = {
    enable = mkEnableOpt "Enable Niri";
    withEffects = mkEnableOpt "Enable Effects like blur, animation shadow";
    rounding = mkOpt types.int 10 "size fo the rounding";
  };

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.niri
    ];
  };
}
