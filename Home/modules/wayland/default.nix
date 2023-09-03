{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.wayland;
in
{
  imports = [
    ./hyprland
    ./sway
    ./newm
  ];

  options.modules.wayland = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = false;
    };
  };


  config = mkIf cfg.enable {
    modules.avizo.enable = true;
    home.packages = with pkgs; [
      # screenshot
      grim
      slurp

      # idle/lock
      # swaybg
      # swaylock-effects

      # utils
      wdisplays
      wf-recorder
      wl-clipboard
      wlogout
      wlr-randr

      swaynotificationcenter
      # wofi
    ];
  };
}
