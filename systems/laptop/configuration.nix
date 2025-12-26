{
  config,
  libCustom,
  pkgs,
  username,
  inputs,
  ...
}:
with libCustom;
{

  imports = [ inputs.nixos-hardware.nixosModules.dell-xps-15-9500 ];

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
    server = {
      media-center = {
        jellyfin = {
          enable = true;
          openFirewall = true;
        };
      };
    };
  };

  zramSwap = {
    enable = true;
    # algorithm = "lzo-rle";
    memoryPercent = 100;
  };

  boot.kernel.sysctl = {
    # Aggressively use zram
    # Higher values will make the kernel prefer swapping out idle processes over dropping caches
    "vm.swappiness" = 180;
    "vm.watermark_boost_factor" = 0;
    "vm.watermark_scale_factor" = 125;
    "vm.page-cluster" = 0;
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

  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-tty;
    # enableSSHSupport = true;
  };

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

  ## Hardware acceleration
  # nixpkgs.config.packageOverrides = pkgs: {
  #   intel-vaapi-driver = pkgs.intel-vaapi-driver.override { enableHybridCodec = true; };
  # };
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

  ## Upower
  services.upower = {
    enable = true;
    percentageLow = 25;
    percentageCritical = 10;
    percentageAction = 5;
    criticalPowerAction = "HybridSleep";
  };

  ## Laptop Lid
  services.logind.settings.Login.HandleLidSwitch = "hybrid-sleep";
  services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
  services.logind.settings.Login.HandlelidSwitchDocked = "ignore";

  # Laptop power
  powerManagement.enable = true;
  powerManagement.powertop.enable = true;
  services.thermald.enable = true;

  environment.systemPackages = with pkgs; [
    config.boot.kernelPackages.cpupower
  ];

  ## Virtual executions

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
