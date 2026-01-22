{
  lib,
  config,
  pkgs,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.system.desktopEnvironment.hypr;
in {
  options.modules.system.desktopEnvironment.hypr = {
    enable = mkEnableOpt "Enable Hyprland Desktop Environment";
  };

  config = mkIf cfg.enable {
    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # This set other option for hyprland, like polkit, portal, dconf, ect...
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      hyprpolkitagent
      rose-pine-hyprcursor
    ];

    programs.hyprlock.enable = true;

    qt = {
      enable = true;
      platformTheme = "qt5ct";
      # style = "kvantum";
    };

    security.polkit.enable = true;

    xdg.portal = {
      xdgOpenUsePortal = true;
      wlr.enable = true;
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-hyprland
      ];
      config.common.default = "*";
      config = {
      };
    };
  };
}
