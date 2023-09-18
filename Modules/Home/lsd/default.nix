{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.lsd;

in {
  options.modules.lsd = {
    enable = mkOption {
      description = "Enable lsd";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.lsd.enable = true;
    xdg.configFile."lsd/config.yaml".source = ./config.yaml;
  };
}
