{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.waydroid;
in
{
  options.modules.waydroid = {
    enable = mkOption {
      description = "Enable waydroid";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    virtualisation.waydroid.enable = true;
  };
}
