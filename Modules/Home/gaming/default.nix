{ pkgs, lib, config, inputs, ... }:
with lib;
let cfg = config.modules.gaming;

in {
  options.modules.gaming = {
    enable = mkOption {
      description = "Enable gaming package and settings";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs;[
      # heroic # FIXME
      inputs.prismlauncher.packages.${pkgs.system}.prismlauncher
      lutris
    ];
  };
}

## TODO SWITCH TO A SYSTEM MODULE