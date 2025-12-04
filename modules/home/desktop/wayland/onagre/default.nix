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
  cfg = config.modules.desktop.wayland.onagre;
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
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/onagre/theme.scss";

    programs.onagre = {
      enable = true;
    };
  };
}
