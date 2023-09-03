{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.wayland.sway;
in
{
  options.modules.wayland.sway = {
    enable = mkOption {
      description = "Enable sway";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable { };
}
