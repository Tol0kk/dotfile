{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.xdg;

in {
  options.modules.xdg = {
    enable = mkOption {
      description = "Enable xdg";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    xdg = {
      enable = true;
    };
  };
}
