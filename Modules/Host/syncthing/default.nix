{ pkgs, lib, config, pkgs-unstable, ... }:

with lib;
let
  cfg = config.modules.syncthing;
in
{
  options.modules.syncthing = {
    enable = mkOption {
      description = "Enable Syncthing";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services = {
      syncthing = {
        enable = true;
        user = "titouan";
        dataDir = "/home/titouan/Documents/Sync"; # Default folder for new synced folders
        configDir = "/home/titouan/.config/syncthing"; # Folder for Syncthing's settings and keys
      };
    };
  };
}
