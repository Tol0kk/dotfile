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
      gitea.enable = true;
      vaultwarden.enable = true;
    };
  };

  # Cross Compile
  nixpkgs.config.allowUnsupportedSystem = true;

  # Boot
  boot.loader.systemd-boot.enable = true;
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

  # Home Assistant
  services.home-assistant = {
    enable = true;
    extraComponents = [
      # Components required to complete the onboarding
      "esphome" # Add ESPHome integration: https://www.home-assistant.io/integrations/esphome/
      "met" #  Weather forecast: https://www.home-assistant.io/integrations/met/
      "radio_browser" # Radio automation: https://www.home-assistant.io/integrations/radio_browser/
      "tuya" # Add Tuya Powered Device Integration: https://www.home-assistant.io/integrations/tuya/
      "zha" # Add Zigbee Home Automation: https://www.home-assistant.io/integrations/zha/
      "thread" # Add Thread integration: https://www.home-assistant.io/integrations/thread/
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
    };
  };
  # TODO See https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=+ocis
  services.ocis.enable = true;
  # TODO see https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=esphome
  services.esphome.enable = true;
  # TODO see https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=immich
  services.immich.enable = true;

  services.radarr.enable = true;
  # services.sonarr.enable = true;
  services.lidarr.enable = true;
  services.jellyfin.enable = true;

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
