{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shells.startship;
in

{
  options.modules.shells.startship = {
    enable = mkOption {
      description = "Enable startship";
      type = types.bool;
      default = false;
    };
  };


  config = mkIf cfg.enable {
    # Configure starship prompt
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
