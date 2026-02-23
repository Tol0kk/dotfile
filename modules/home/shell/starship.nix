{
  lib,
  config,
  libCustom,
  pkgs,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.shell.starship;
in
{
  options.modules.shell.starship = {
    enable = mkEnableOpt "Enable Starship";
  };

  config = mkIf cfg.enable {
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
