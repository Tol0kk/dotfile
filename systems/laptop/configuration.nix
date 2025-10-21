{
  config,
  libCustom,
  pkgs,
  username,
  ...
}:
with libCustom;
{
  modules = {
    hardware = {
      bluetooth = enabled;
      nvidia = enabled;
      network.wifi-profiles = enabled;
      udev.enableExtraRules = true;
    };
    users = {
      titouan = enabled;
    };
    system = {
      zfs.enable = true;
      persist.enable = true;
      boot.limine = enabled;
      boot.plymouth = enabled;
      ssh = enabled;
      sops.enable = true;
      sops.keyFile = "${config.users.users.titouan.home}/.config/sops/age/keys.txt";
    };
    services = {
      # restic = enabled; # Backup
    };
    archetype.workstation = enabled;
    archetype.gamingstation = enabled;
    apps.tools.security.enable = true;
  };

  zramSwap = {
    algorithm = "lzo-rle";
  };

  # Optional: Information Given for generating systems topology
  topology.self = {
    name = "💻  Laptop";
    hardware.info = "i7 10750H | 32GB | GTX 1650Ti";
    interfaces.wg0 = {
      addresses = [ "10.100.0.2" ];
      network = "wg0"; # Use the network we define below
      type = "wireguard"; # changes the icon
      physicalConnections = [
        (config.lib.topology.mkConnection "olympus" "wg0")
      ];
    };
    interfaces.wlp30s0 = {
      addresses = [ "192.168.1.78/24" ];
      network = "home"; # Use the network we define below
    };
  };

  services.greetd.enable = true;
  services.greetd.settings.default_session.command =
    "${pkgs.greetd}/bin/agreety --cmd ${pkgs.bashInteractive}/bin/bash";
  services.greetd.settings.initial_session.user = "titouan";
  services.greetd.settings.initial_session.command = "Hyprland";

  # boot.initrd.systemd = {
  #   enable = true;
  #   services.initrd-rollback-root = {
  #     after = [ "zfs-import-rpool.service" ];
  #     wantedBy = [ "initrd.target" ];
  #     before = [
  #       "sysroot.mount"
  #     ];
  #     path = [ pkgs.zfs ];
  #     description = "Rollback root fs";
  #     unitConfig.DefaultDependencies = "no";
  #     serviceConfig.Type = "oneshot";
  #     script = "zfs rollback -r rpool/nixos/root@start";
  #   };
  # };

  networking.hostId = "0be1cd29";

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
