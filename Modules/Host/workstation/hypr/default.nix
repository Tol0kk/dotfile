{ pkgs, self, inputs, lib, config, ... }:

with lib;
let
  cfg = config.modules.workstation.hypr;
in
mkIf cfg.enable  {
    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # This set other option for hyprland, like polkit, portal, dconf, ect... 
    programs.hyprland.enable = true;
}
