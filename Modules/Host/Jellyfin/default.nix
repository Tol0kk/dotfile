{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.jellyfin;
in
{
  options.modules.jellyfin = {
    enable = mkOption {
      description = "Enable Jellyfin";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.jellyfin.enable = true;
  };
}
