{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.nix-index;

in {
  options.modules.nix-index = {
    enable = mkOption {
      description = "Enable nix-index";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    programs.command-not-found.enable = false;
  };
}
