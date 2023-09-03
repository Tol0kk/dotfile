{ pkgs, lib, config, inputs, self, ... }:
with lib;
let cfg = config.modules.ags;

in {
  options.modules.ags = {
    enable = mkOption {
      description = "Enable ags";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ inputs.ags.packages.${pkgs.system}.default pkgs.sassc pkgs.glib pkgs.brightnessctl ];
  };
}
