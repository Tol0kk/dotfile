{ config, lib, pkgs, self, pkgs-unstable, ... }:

{
  modules = {
    sops.enable = true;

    server = {
      cloudflared = {
        enable = true;
        domain = "tolok.org";
        tunnelId = "ab1ecc34-4d1c-4356-88e7-ba7889c654ad";
      };
      gitea.enable = true;
      vaultwarden.enable = true;
    };
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

  # Server Service #

  # CloudFlare Tunnels
  sops.secrets."services/cloudflared_HOME_TOKEN" = { owner = config.services.cloudflared.user; };
  services.cloudflared = {
    tunnels = {
      "${config.modules.server.cloudflared.tunnelId}" = {
        credentialsFile = "${config.sops.secrets."services/cloudflared_HOME_TOKEN".path}";
        ingress = {
          "www.tolok.org" = {
            service = "http://localhost:8000";
            path = "/index.html";
          };
          "servrock.tolok.org" = {
            service = "ssh://servrock:22";
          };
          "desktop.tolok.org" = {
            service = "ssh://desktop:22";
          };
          "laptop.tolok.org" = {
            service = "ssh://laptop:22";
          };
        };
        default = "http_status:404";
      };
    };
  };
  
  # Fix shell 

  environment.shellInit = ''
    export TERM=xterm
  '';

}

