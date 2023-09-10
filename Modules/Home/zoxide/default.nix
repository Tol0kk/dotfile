{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.zoxide;

in {
  options.modules.zoxide = {
    enable = mkOption {
      description = "Enable zoxide";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
  };
}
