{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.gpg;

in {
  options.modules.gpg = {
    enable = mkOption {
      description = "Enable gpg";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.gpg = {
      enable = true;
    };
    services.gpg-agent = {
      enable = true;
      pinentryFlavor = "qt";
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      enableSshSupport = true; # TODO is it usefull ? 
    };
  };
}
