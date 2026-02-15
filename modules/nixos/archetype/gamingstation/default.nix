{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.archetype.gamingstation;
in
{
  options.modules.archetype.gamingstation = {
    enable = mkEnableOpt "Enable Gaming";
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
    hardware.steam-hardware.enable = true;
    programs.steam.gamescopeSession.enable = true;
    programs.gamemode.enable = true;
    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };
    environment.systemPackages = with pkgs; [
      prismlauncher
      # heroic
      # lutris
      # bottles
    ];
  };
}
