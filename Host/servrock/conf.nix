{ lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "nvme" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/3fd86c71-803a-47b1-a5eb-268c7f32188c";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/FC26-E381";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/4da9212d-5233-4bc5-a10b-ec35b1f7596d"; }];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  # nixpkgs.crossSystem.system = "aarch64-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  networking.hostName = "servrock"; # Define your hostname
  time.timeZone = "Europe/Paris";

  console = {
    keyMap = "fr";
  };

  users.users.titouan = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
    packages = with pkgs; [
      tree
    ];
  };

  environment.systemPackages = with pkgs; [
    wget
    lsd
    btop
    ripgrep
    neovim
    git
    zoxide
    file
  ];

  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = false;
  services.openssh.knownHosts.titouan.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKzcm3GzMAzxobh8g3xGwI4RbgKLUc9k4mm+bT4MXtH titouan.le.dilavrec@gmail.com";
  services.openssh.knownHosts.root.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKzcm3GzMAzxobh8g3xGwI4RbgKLUc9k4mm+bT4MXtH titouan.le.dilavrec@gmail.com";

  networking.firewall.enable = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
