{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.wayland.hyprland;
  nvidiacfg = config.modules.nvidia;
in
{
  options.modules.wayland.hyprland = {
    enable = mkOption {
      description = "Enable hyprland";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      enableNvidiaPatches = true;
    };
    programs.waybar.enable = true;
    xdg.configFile."hypr/hyprland.conf".source = ./hyprland.conf;
    home.packages = with pkgs; [
      hyprpicker
      playerctl
    ];
  };
}
