{
  flake.homeModules.starship =
    {
      lib,
      pkgs,
      ...
    }:
    {
      programs.starship = {
        enable = true;
        package = pkgs.starship;
        enableBashIntegration = true;
        enableFishIntegration = true;
        enableNushellIntegration = true;
        enableZshIntegration = true;
        enableTransience = true;
        settings = {
          add_newline = false;
        };
      };
    };
}
