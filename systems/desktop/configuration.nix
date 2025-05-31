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
      # network.wifi-profiles = enabled;
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
    };
    services = {
      # restic = enabled; # Backup
      ollama = disabled;
    };
    archetype.workstation = enabled;
    archetype.gamingstation = enabled;
    apps.tools.security.enable = true;
    # sops.enable = true;
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

  programs.nix-ld.enable = true;

  # Sets up all the libraries to load
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    fuse3
    icu
    nss
    openssl
    curl
    expat
    # ...
  ];

  # Public ssh keu authorized to connect to desktop
  users.users.titouan = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
    ];
  };

  # LUCKS: Activate encription
  boot.initrd.luks.devices."luks-c19801cf-8ba0-488b-97d1-959651c21ab9".device = "/dev/disk/by-uuid/c19801cf-8ba0-488b-97d1-959651c21ab9";

  # TODO change because startup crash with gdm (deactivate gdm)
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = "titouan";

  # TODO Move to system/virtualisation maybe
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  system.stateVersion = "24.11"; # Did you read the comment?
}
