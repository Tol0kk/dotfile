{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gaming;
in
{
  options.modules.gaming = {
    enable = mkOption {
      description = "Enable gaming";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
