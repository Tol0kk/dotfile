{
  config,
  libCustom,
  pkgs,
  modulesPath,
  lib,
  self,
  inputs,
  ...
}:
with libCustom;
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  modules = {
    hardware = {
      audio = enabled;
      bluetooth = enabled;
      network.wifi-profiles = enabled;
      filesystems.ntfs = enabled;
    };
    users = {
      titouan = enabled;
    };
    system = {
      boot.limine = enabled;
      ssh = enabled;
      sops.enable = true;
      sops.keyFile = "${config.users.users.titouan.home}/.config/sops/age/keys.txt";
      fonts = enabled;
      desktopEnvironment.hypr = enabled;
    };
    apps.neovim.enable = true;
    apps.neovim.custom.enable = true;
    apps.neovim.custom.minimal = false;
    apps.thunar.enable = true;
  };

  isoImage.contents = [
    {
      source = self;
      target = "content/config";
    }
  ];

  services.getty.autologinUser = lib.mkForce "titouan";

  networking.networkmanager.enable = true;
  services.udisks2.enable = true;
  programs.dconf.enable = true;
  programs.ssh.startAgent = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;
  programs.nix-index.enableFishIntegration = true;
  programs.nix-index.enableBashIntegration = true;
  programs.command-not-found.enable = false;

  programs.direnv.enable = true;
  programs.direnv.silent = true;
  programs.direnv.nix-direnv.enable = true;

  environment.systemPackages = with pkgs; [
    yazi
    file
    tldr
    btop
    imv
    unzip
    busybox
    openssl
    disko
    zfs
    gparted
    tparted
    home-manager
  ];

  boot = {
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "reiserfs"
      "vfat"
      "f2fs"
      "xfs"
      "xfs"
      "zfs"
      "ntfs"
      "cifs"
    ];
  };

  users.extraUsers.root.initialPassword = "nixos";
  users.extraUsers.root.initialHashedPassword = lib.mkForce null;

  system.stateVersion = "25.11"; # Did you read the comment?
}
