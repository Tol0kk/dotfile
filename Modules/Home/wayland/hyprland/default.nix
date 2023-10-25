{ pkgs, lib, config, color, ... }:

with lib;
let
  cfg = config.modules.wayland.hyprland;
  nvidiacfg = config.modules.nvidia;
  themecfg = config.modules.theme;
  colorScheme = config.modules.theme.colorScheme;
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
    xdg.configFile."hypr/hyprland_test.conf".text =
      ''
        aa = ${color.toGradiant [colorScheme.border1 colorScheme.border2 colorScheme.border1 colorScheme.border2 colorScheme.border1] 45}
      '';
    home.packages = with pkgs; [
      hyprpicker
      playerctl
      sway-contrib.grimshot
    ];
  };
}
