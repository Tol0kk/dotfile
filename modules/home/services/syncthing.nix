{
  lib,
  config,
  pkgs,
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

  config = mkIf cfg.enable {
    # services = {
    #   syncthing = {
    #     enable = true;
    #     user = "titouan";
    #     dataDir = "${config.users.users.${mainUser}.home}/Documents/Sync"; # Default folder for new synced folders
    #     configDir = "${config.users.users.${mainUser}.home}/.config/syncthing"; # Folder for Syncthing's settings and keys
    #   };
    # };

    services.syncthing = {
      enable = true;
      tray = {
        enable = true;
        package = pkgs.syncthingtray;
        command = "syncthingtray --wait";
      };
    };

    # Workaround for Failed to restart syncthingtray.service: Unit tray.target not found.
    # - https://github.com/nix-community/home-manager/issues/2064
    systemd.user.targets.tray = {
      Unit = {
        Description = "Home Manager System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };
  };
}
