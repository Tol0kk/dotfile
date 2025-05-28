{
  lib,
  config,
  mainUser,
  ...
}:
with lib; let
  cfg = config.modules.syncthing;
in {
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
        dataDir = "${config.users.users.${mainUser}.home}/Documents/Sync"; # Default folder for new synced folders
        configDir = "${config.users.users.${mainUser}.home}/.config/syncthing"; # Folder for Syncthing's settings and keys
      };
    };
  };
}
