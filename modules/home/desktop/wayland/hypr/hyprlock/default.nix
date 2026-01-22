{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.desktop.wayland.hypr.hyprpanel;
in {
  options.modules.desktop.wayland.hypr.hyprlock = {
    enable = mkEnableOpt "Enable Hyprlock";
  };

  config = mkIf cfg.enable {
    home.file.".config/hypr/hyprlock.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/hypr/hyprlock/style-1/hyprlock.conf";
  };
}
