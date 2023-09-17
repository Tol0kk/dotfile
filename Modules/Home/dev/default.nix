{ pkgs, lib, config, self, ... }:

with lib;
let
  cfg = config.modules.dev;
in
{
  imports =
    (builtins.map (dir: "${self}/Modules/Home/dev/" + dir)
      (builtins.filter (name: !(hasSuffix ".nix" name))
        (builtins.attrNames (builtins.readDir "${self}/Modules/Home/dev"))));

  options.modules.dev = {
    enable = mkOption {
      description = "Enable dev basic component";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    modules.git.enable = true;
    home.packages = with pkgs; [
      vscodium
      blender
      platformio # update/upload firmware on a board
      avrdude
      printrun # control 3dprinter manualy
      minicom # serial comunication
      openocd # on-chip debugging
      traceroute
      ripgrep
      lsof
      wget
      curl
      poppler_utils # BASH SYS
      img2pdf # BASH SYS
      tldr
    ];
  };
}
