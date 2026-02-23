{
  pkgs,
  lib,
  config,
  inputs,
  libCustom,
  isPure,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.desktop.wayland.shells.noctalia;
  mkSource = relPath: absPath:
    if isPure
    then relPath
    else config.lib.file.mkOutOfStoreSymlink absPath;
in {
  options.modules.desktop.wayland.shells.noctalia = {
    enable = mkEnableOpt "Enable Noctalia Shell (Quickshell)";
  };

  imports = [
    inputs.noctalia.homeModules.default
  ];

  config = mkIf cfg.enable {
    stylix.targets.noctalia-shell.enable = false;
    programs.noctalia-shell = {
      enable = true;
    };

    home.file.".config/noctalia" = {
      source = mkSource ./config "${config.dotfiles}/modules/home/desktop/wayland/shells/noctalia/config";
      recursive = true;
    };
    home.sessionVariables = {
      # QT_QPA_PLATFORMTHEME = "gtk3";
    };

    home.packages = [
      pkgs.quickshell
      pkgs.gpu-screen-recorder
    ];
  };
}
