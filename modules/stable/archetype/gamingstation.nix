{
  flake.nixosModules.gamingstation =
    {
      pkgs,
      lib,
      config,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    {
      programs.steam.enable = true;
      programs.steam.extraCompatPackages = with pkgs; [
        proton-ge-bin
      ];
      hardware.steam-hardware.enable = true;
      # programs.steam.gamescopeSession.enable = true;
      # programs.gamemode.enable = true;
      programs.gamescope = {
        enable = true;
        capSysNice = false;
      };
      services.ananicy = {
        extraRules = [
          {
            "name" = "gamescope";
            "nice" = -20;
          }
        ];
      };
      environment.systemPackages = with pkgs; [
        prismlauncher
        # heroic
        lutris
        # bottleso
      ];
    };
}
