{
  pkgs,
  lib,
  config,
  libCustom,
  isPure,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.desktop.wayland.onagre;
  mkSource =
    relPath: absPath: if isPure then relPath else config.lib.file.mkOutOfStoreSymlink absPath;
in
{
  options.modules.desktop.wayland.onagre = {
    enable = mkEnableOpt "Enable Onagre an application launcher";
  };

  # TODO Clean UP
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xdg-utils
    ];

    home.file.".config/onagre/theme.scss".source =
      mkSource ./theme.scss "${config.dotfiles}/modules/home/desktop/wayland/onagre/theme.scss";

    programs.onagre = {
      enable = true;
    };
  };
}
