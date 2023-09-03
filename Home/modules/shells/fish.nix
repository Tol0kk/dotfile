{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shells.fish;
in

{
  options.modules.shells.fish = {
    enable = mkOption {
      description = "Enable fish";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting # Disable greeting
      '';
      shellAbbrs = import ./aliases.nix;
    };
  };
}
