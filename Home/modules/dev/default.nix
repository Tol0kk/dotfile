{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev;
in
{
  imports = [
    ./nix
    ./octave
    ./R
    ./rust
    ./android
  ];
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
      vscodium-fhs
      vscode-fhs
      blender
      platformio # update/upload firmware on a board
      printrun # control 3dprinter manualy
      minicom # serial comunication
      openocd # on-chip debugging
      ripgrep
      lsof
      wget
      curl
      tldr
    ];
  };
}
