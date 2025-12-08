{
  pkgs,
  lib,
  config,
  inputs,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.desktop.wayland.shells.noctalia;
in
{
  options.modules.desktop.wayland.shells.noctalia = {
    enable = mkEnableOpt "Enable Noctalia Shell (Quickshell)";
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = mkIf cfg.enable {
    programs.noctalia-shell = {
      enable = true;
    };

    home.file.".config/noctalia".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/shells/noctalia/config";

    home.sessionVariables = {
      # QT_QPA_PLATFORMTHEME = "gtk3";
    };

    home.packages = [
      pkgs.quickshell
    ];
  };
}
