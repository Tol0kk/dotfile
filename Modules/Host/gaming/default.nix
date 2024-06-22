{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming = {
    enable = mkOption {
      description = "Enable Gaming";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    programs.steam.gamescopeSession.enable = true;
    environment.systemPackages = with pkgs; [
      prismlauncher
      heroic
      # unigine-heaven
      lutris
    ];
  };
}
