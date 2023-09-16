{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.eww;

in {
  options.modules.eww = {
    enable = mkOption {
      description = "Enable Sway notification center";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      eww-wayland
      pulseaudio
    ]; 
  };
}
