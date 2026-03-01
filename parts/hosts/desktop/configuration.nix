{ self, config, ... }:
{
  imports = [
    # Archetype
    self.nixosModules.workstation
    self.nixosModules.devstation
    self.nixosModules.gamingstation
    self.nixosModules.builder
    self.nixosModules.securitystation-essenstials
    self.nixosModules.server

    # System
    self.nixosModules.grub
    # self.nixosModules.limine
    self.nixosModules.plymouth
    self.nixosModules.nvidia
    self.nixosModules.bluetooth
    self.nixosModules.docker

    # Apps
    # self.nixosModules.neovim

    # DE
    self.nixosModules.niri

    # Users
    self.nixosModules.titouan
    self.nixosModules.titouan-autologin
    self.nixosModules.titouan-home
  ];

  # Topology
  topology.self = {
    name = "🖥️ Desktop";
    hardware.info = "R5 1600 | 16GB | GTX 1070";
    interfaces.wg0 = {
      addresses = [ "10.100.0.3" ];
      network = "wg0"; # Use the network we define below
      type = "wireguard"; # changes the icon
      physicalConnections = [
        (config.lib.topology.mkConnection "olympus" "wg0")
      ];
    };
    interfaces.enp25s0 = {
      addresses = [ "192.168.1.xxx/24" ];
      # network = "home"; # Use the network we define below
    };
    interfaces.wlp30s0 = {
      addresses = [ "192.168.1.64/24" ];
      network = "home"; # Use the network we define below
    };
  };

  # Limits jobs for the pc to survive while building XD
  nix = {
    settings = {
      cores = 6;
    };
  };

  # To boot
  fileSystems."/home".neededForBoot = true;
  boot.initrd.systemd.enable = true;

  # LUCKS: Activate encription
  boot.initrd.luks.devices."luks-c19801cf-8ba0-488b-97d1-959651c21ab9".device =
    "/dev/disk/by-uuid/c19801cf-8ba0-488b-97d1-959651c21ab9";

  # TODO Move to system/virtualisation maybe
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # TODO why ???
  boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
  boot.kernelModules = [ "ddcci_backlight" ];
  hardware.i2c.enable = true;
}
