{ pkgs, lib, config, self, ... }:

with lib;
let
  cfg = config.modules.wayland;
in
{
  imports =
    (builtins.map (dir: "${self}/Modules/Home/wayland/" + dir)
      (builtins.filter (name: !(hasSuffix ".nix" name))
        (builtins.attrNames (builtins.readDir "${self}/Modules/Home/wayland"))));

  options.modules.wayland = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = false;
    };
  };


  config = mkIf cfg.enable {
    modules.avizo.enable = true;
    home.sessionVariables = {
      NIXOS_OZONE_WL = "1";
    };
    home.packages = with pkgs; [
      # screenshot
      grim
      slurp
      swappy      watershot
      neofetch

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
