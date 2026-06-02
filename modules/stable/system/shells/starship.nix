{
  flake.homeModules.starship =
    {
      lib,
      pkgs,
      ...
    }:
    {
      key = "homeModules.starship";
      programs.starship = {
        enable = true;
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
