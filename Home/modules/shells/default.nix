{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.shells;
in
{
  imports = [
    ./zsh.nix
    ./fish.nix
    ./bash.nix
    ./starship.nix
  ];
  
  options.modules.shells = {
    enable = mkOption {
      description = "Enable shells";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.shellAliases = import ./aliases.nix;
  };
}
