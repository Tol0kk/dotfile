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
  cfg = config.modules.system.desktopEnvironment.hypr;
in
{
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

    security.polkit.enable = true;
  };
}
