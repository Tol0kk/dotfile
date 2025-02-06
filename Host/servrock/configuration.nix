{
  pkgs,
  config,
  ...
}: {
  modules = {
    sops.enable = true;
    server = {
      cloudflared = {
        enable = true;
        domain = "tolok.org";
        tunnelId = "ab1ecc34-4d1c-4356-88e7-ba7889c654ad";
      };
      gitea.enable = false;
      media-center.enable = false;
      forgejo.enable = false;
      kanidm.enable = true;
      wireguard.enable = false;
      prometheus-node-exporter.enable = false;
      own-cloud.enable = false;
      esp-home.enable = false;
      uptime-kuma.enable = false;
      home-assistant.enable = true;
      vaultwarden.enable = true;
    };
  };

  # Cross Compile
  nixpkgs.config.allowUnsupportedSystem = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
  # Limit the number of configuration, Useful to prevent boot partition running out of disk space.
  boot.loader.systemd-boot.configurationLimit = 10;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = false;

  programs.command-not-found.enable = false;

  system.stateVersion = "24.05"; # Did you read the comment?

  # Server Service #
  # CloudFlare Tunnels
  sops.secrets."services/cloudflared_HOME_TOKEN" = {owner = config.services.cloudflared.user;};
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

  services.dbus.implementation = "broker";

  environment.systemPackages = with pkgs; [
    pkgs.assets
    pkgs.htop
    stress
    qbittorrent
  ];

  networking.firewall.allowedTCPPorts = [
    8123 # Home Assistant
  ];

  # Fix shell

  environment.shellInit = ''
    export TERM=xterm
  '';
}
