{ config, lib, pkgs, self, pkgs-unstable, ... }:

{
  modules = {
    sops.enable = true;
    cloudflared = {
      enable = true;
      domain = "tolok.org";
      tunnelId = "ab1ecc34-4d1c-4356-88e7-ba7889c654ad";
    };
    gitea.enable = true;
    vaultwarden.enable = true;
  };

  # Cross Compile
  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.hostPlatform.system = "aarch64-linux";
  nixpkgs.buildPlatform.system = "x86_64-linux";

  # Boot 
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  programs.command-not-found.enable = false;

  system.stateVersion = "24.05"; # Did you read the comment?
}

