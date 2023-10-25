{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.network;
in
{
  options.modules.network = {
    enable = mkOption {
      description = "Enable network";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    
    
    
  };
}
