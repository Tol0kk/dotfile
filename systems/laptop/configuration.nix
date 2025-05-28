{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  modules = {
    neovim.custom.minimal = false;
    bluetooth.enable = true;
    workstation = {
      enable = true;
      hypr.enable = true;
      gnome.enable = true;
    };
    network-profiles.enable = true;
    syncthing.enable = true;
    fonts.enable = true;
    tools.security.enable = true;
    gaming.enable = true;
    nvidia = {
      enable = true;
      offload = {
        enable = false;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    sops.enable = true;
    boot.grub.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.kvm.enable = true;
    udev.enableExtraRules = true;
  };

  # Optional: Information Given for generating systems topology
  topology.self = {
    name = "💻  Laptop";
    hardware.info = "i7 10750H | 32GB | GTX 1650Ti";
    interfaces.wg0 = {
      addresses = ["10.100.0.2"];
      network = "wg0"; # Use the network we define below
      type = "wireguard"; # changes the icon
      physicalConnections = [
        (config.lib.topology.mkConnection "olympus" "wg0")
      ];
    };
    interfaces.wlp30s0 = {
      addresses = ["192.168.1.78/24"];
      network = "home"; # Use the network we define below
    };
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    bash
    zlib
    fuse3
    icu
    zlib
    nss
    openssl
    curl
    expat
    envfs
  ];

  environment.systemPackages = with pkgs; [
    nix-ld
    git
    envfs
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Prevent sshd to start automaticly on laptop. (make the system safer)
  systemd.services.sshd.wantedBy = lib.mkForce [];

  # services.fprintd = {
  # enable = true;
  # tod.enable = true;
  # tod.driver = pkgs.libfprint-2-tod1-goodix;
  # };
  # security.pam.services.${mainUser}.fprintAuth = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
