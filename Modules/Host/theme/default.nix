{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.theme;
  # SF-Mono = pkgs.callPackage ../../pkgs/apple-theme {};
in
{
  options.modules.theme = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = true;
    };
  };


  config = mkIf cfg.enable {
    
  };
}
