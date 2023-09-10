{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.direnv;

in {
  options.modules.direnv = {
    enable = mkOption {
      description = "Enable direnv";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableNushellIntegration = true;
      # enableFishIntegration= true;
      nix-direnv.enable = false;
    };
  };
}
