{
  config,
  libCustom,
  pkgs,
  inputs,
  ...
}:
with libCustom;
{
  imports = [ inputs.nixos-hardware.nixosModules.dell-xps-15-9500 ];

  # sops.secrets."delugeAuthFile" = {
  #   owner = config.services.deluge.user;
  #   group = config.services.deluge.group;
  #   mode = "0600";
  #   sopsFile = ./secrets.yaml;
  # };

  sops.secrets.binaryCacheSecretKey = {
    sopsFile = ./secrets.yaml;
  };

  modules = {
    hardware = {
      bluetooth = enabled;
      nvidia = {
        enable = true;
        powerManagement.enable = true;
      };
      network.wifi-profiles = enabled;
      udev.enableExtraRules = true;
    };
    users = {
      titouan = {
        enable = true;
        auto-login = true;
      };
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
      # pixiecore = disabled; # Need port 80, imcompatible with traefik
      # glance = enabled;
      # jellyfin = enabled;
      # deluge = {
      #   enable = true;
      #   authFileSecretsPath = config.sops.secrets."delugeAuthFile".path;
      # };
      # traefik = {
      #   enable = true;
      # };
    };
    archetype = {
      workstation = enabled;
      gamingstation = enabled;
      security = enabled;
      laptop = enabled;
    };
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
  services.greetd.settings.initial_session.command = "niri-session";

  # Impermanance
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

  ## Hardware acceleration
  hardware.graphics = {
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      libvdpau-va-gl
    ];
  };
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };

  ## Virtual executions
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Nix deamon signing key
  nix.settings = {
    secret-key-files = config.sops.secrets.binaryCacheSecretKey.path;
  };

  system.stateVersion = "24.05";
  networking.hostId = "0be1cd29";
}
