{
  pkgs,
  lib,
  assets,
  config,
  inputs,
  libCustom,
  isPure,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.desktop.wayland.niri;

  mkSource =
    relPath: absPath: if isPure then relPath else config.lib.file.mkOutOfStoreSymlink absPath;
in
{
  options.modules.desktop.wayland.niri = {
    enable = mkEnableOpt "Enable Niri";
    withEffects = mkEnableOpt "Enable Effects like blur, animation shadow";
    rounding = mkOpt types.int 10 "size fo the rounding";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      "QT_QPA_PLATFORMTHEME" = "gtk3";
    };

    home.file.".config/niri".source =
      mkSource ./config "${config.dotfiles}/modules/home/desktop/wayland/niri/config";
    home.packages = [
      pkgs.niri
      pkgs.gpu-screen-recorder
    ];
  };
}
