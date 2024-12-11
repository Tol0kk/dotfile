{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.yazi;

in {
  options.modules.yazi = {
    enable = mkOption {
      description = "Enable Yazi";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      keymap = { };
      settings = {
        log = {
          enabled = false;
        };
      };
    };

  };
}
