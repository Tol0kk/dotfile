{
  config,
  libCustom,
  pkgs,
  ...
}:
with libCustom; {
  modules = {
    hardware = {
      bluetooth = enabled;
      nvidia = enabled;
      udev.enableExtraRules = true;
      network.wifi-profiles = enabled;
    };
    users = {
      titouan = enabled;
      builder = enabled;
    };
    system = {
      boot.grub = enabled;
      boot.plymouth = enabled;
      ssh.enable = true;
      stylix.enable = true;
      ssh.auto-start-sshd = true;
      sops.enable = true;
      sops.keyFile = builtins.trace "${config.users.users.titouan.home}/.config/sops/age/keys.txt" "${config.users.users.titouan.home}/.config/sops/age/keys.txt";
    };
    services = {
      # restic = enabled; # Backup
      ollama = disabled;
    };
    archetype.workstation = enabled;
    archetype.gamingstation = enabled;
    apps.tools.security.enable = true;
  };

  # Optional: Information Given for generating systems topology
  topology.self = {
    name = "🖥️ Desktop";
    hardware.info = "R5 1600 | 16GB | GTX 1070";
    interfaces.wg0 = {
      addresses = ["10.100.0.3"];
      network = "wg0"; # Use the network we define below
      type = "wireguard"; # changes the icon
      physicalConnections = [
        (config.lib.topology.mkConnection "olympus" "wg0")
      ];
    };
  };

  # Need for sops
  # fileSystems."/home".neededForBoot = lib.strings.hasPrefix "/home" config.modules.system.sops.keyFile; # Make sure that /home is mounted for sops runtime a boot

  environment.systemPackages = with pkgs; [
    (python312Full.withPackages (python-pkgs:
      with python-pkgs; [
        # select Python packages here
        pyyaml
        requests
      ]))
    cmake
    gnumake
    espup
    cargo
    rustup
    gcc
    arduino-ide
    pkg-config
    #(espflash.overrideAttrs (oldAttrs: rec {
    #  name = "espflash-git";
    #  version = "git";
    #  src = inputs.espflash;
    #  cargoDeps = oldAttrs.cargoDeps.overrideAttrs (lib.const {
    #    name = "${name}-vendor";
    #    inherit src;
    #    outputHash = "sha256-QCEyl5FZqECYYb5eRm8mn+R6owt+CLQwCq/AMMPygE0=";
    #  });
    #}))
    probe-rs-tools
    openssl.dev
    ncurses
    flex
    bison # linux kernel
  ];

  programs.nix-ld.enable = true;

  # Sets up all the libraries to load
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    libusb1
    zlib
    fuse3
    icu
    ncurses
    openssl.dev
    openssl
    nss
    openssl
    curl
    expat
    # ...
  ];

  zramSwap = {
    algorithm = "zstd";
  };

  # Public ssh keu authorized to connect to desktop
  users.users.titouan = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
    ];
  };

  fileSystems."/home".neededForBoot = true;
  boot.initrd.systemd.enable = true;

  # LUCKS: Activate encription
  boot.initrd.luks.devices."luks-c19801cf-8ba0-488b-97d1-959651c21ab9".device = "/dev/disk/by-uuid/c19801cf-8ba0-488b-97d1-959651c21ab9";

  # TODO change because startup crash with gdm (deactivate gdm)
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "titouan";

  # TODO Move to system/virtualisation maybe
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  boot.extraModulePackages = [config.boot.kernelPackages.ddcci-driver];
  boot.kernelModules = ["ddcci_backlight"];

  hardware.i2c.enable = true;

  system.stateVersion = "24.11"; # Did you read the comment?
}
