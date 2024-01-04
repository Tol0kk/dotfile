{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.avizo;

in {
  options.modules.avizo = {
    enable = mkOption {
      description = "Enable avizo";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.pamixer ];
    services.avizo.enable = true;
    services.avizo.settings = {
      default = {
        y-offset = 0.95;
        border-radius = 30;
        block-height = 10;
        block-spacing = 5;
        block-count = 20;
        # background = "rgba (140, 140, 140, 0.4)";
      };
    };
  };
}