{ self, inputs, ... }:
{
  # ── Topology / service catalogue ────────────────────────────────────────
  topology.self = {
    name = "💻  Laptop";
    hardware.info = "i7 10750H | 32GB | GTX 1650Ti";
    interfaces.wlp30s0 = {
      addresses = [ "192.168.1.78/24" ];
      # network = "home"; # Use the network we define below
    };
  };

  # ── Modules Imports ────────────────────────────────────────
  imports = [
    # Archetype
    self.nixosModules.workstation
    self.nixosModules.devstation
    self.nixosModules.gamingstation
    self.nixosModules.securitystation-essenstials

    # System
    self.nixosModules.limine
    self.nixosModules.plymouth
    self.nixosModules.nvidia
    self.nixosModules.bluetooth
    self.nixosModules.docker

    # Harware
    inputs.nixos-hardware.nixosModules.dell-xps-15-9500
    self.nixosModules.zfs
    self.nixosModules.impermanance

    # Apps
    self.nixosModules.neovim

    # DE
    self.nixosModules.niri

    # Users
    self.nixosModules.titouan
    self.nixosModules.titouan-autologin
    self.nixosModules.titouan-home
  ];

  # ── Globals Preferences ────────────────────────────────────────
  # preferences = {
  #   topDomain = "laptop.tolok.org";
  #   openFirewall = false;
  #   public = false;
  # };

  # ── Secrets Declaration ────────────────────────────────────────

  # ── Miscs ────────────────────────────────────────

  fileSystems."/home".neededForBoot = true;

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  networking.hostId = "0be1cd29";
}
