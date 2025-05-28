{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.services.syncthing;
in {
  options.modules.services.syncthing = {
    enable = mkEnableOpt "Enable Syncthing";
  };

  # TODO check
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
