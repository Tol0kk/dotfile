{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.wayland.newm;
in
{
  options.modules.wayland.newm = {
    enable = mkOption {
      description = "Enable newm";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      inputs.newm.packages.${pkgs.system}.newm-atha
    ];
  };
}
