{
  lib,
  config,
  pkgs,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.system.desktopEnvironment.niri;
in
{
  options.modules.system.desktopEnvironment.niri = {
    enable = mkEnableOpt "Enable Niri Desktop Environment";
  };

  config = mkIf cfg.enable {
    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    environment.systemPackages = with pkgs; [
      rose-pine-hyprcursor
    ];

    programs.niri.enable = true;
    programs.xwayland.enable = false;

    security.polkit.enable = true;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      config.common.default = "*";
      config = {
      };
    };

    # services.displayManager.defaultSession = "niri";
  };
}
