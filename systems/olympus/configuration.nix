{
  pkgs,
  config,
  mainUser,
  inputs,
  lib,
  ...
}: {
  # boot.kernelPackages = pkgs.linuxPackages_6_12;
  # boot.kernelPackages = pkgs.linuxPackages_5_15;

  modules = {
    sops.enable = true;
    server = {
      cloudflared = {
        enable = true;
        domain = "tolok.org";
        tunnelId = "ab1ecc34-4d1c-4356-88e7-ba7889c654ad";
      };
      media-center = {
        deluge.enable = true;
        jellyfin.enable = true;
      };
      matrix-conduit.enable = true;
      forgejo.enable = true;
      grafana.enable = true;
      kanidm.enable = true;
      wireguard.enable = true;
      glance.enable = true;
      prometheus.enable = true;
      loki.enable = true;
      promtail.enable = true;
      prometheus-node-exporter.enable = true;
      own-cloud.enable = true;
      # esp-home.enable = true;
      uptime-kuma.enable = true;
      home-assistant.enable = true;
      vaultwarden.enable = true;
      fail2ban.enable = true;
    };
  };

  # Optional: Information Given for generating systems topology
  topology.self = {
    name = "Olympus";
    hardware.info = "Radxa 5B | 16GB";
  };

  systemd.network.enable = true;
  systemd.network.networks.enP4p1s0 = {
    matchConfig.Name = "enP4p1s0";
    address = ["192.168.1.48/24"];
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
  networking.networkmanager.enable = true;

  programs.command-not-found.enable = false;
  services.resolved.enable = false;
  # networking.dhcpcd.persistent = true;

  # networking.enableIPv6 = true;
  # networking.useDHCP = true;

  # system.stateVersion = "24.05"; # Did you read the comment?

  # networking.defaultGateway = {
  #   address = "192.168.1.1";
  #   interface = "ens3";
  # };
  # networking.defaultGateway6 = {
  #   address = "2a02:842a:3ba7:a201::1";
  #   interface = "ens3";
  # };
  networking.interfaces.enP4p1s0.ipv6.addresses = [
    {
      address = "2a02:842a:3ba7:a201:b188:2909:4e2a:7f50";
      prefixLength = 64;
    }
  ];

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

  # Fix shell
  environment.shellInit = ''
    export TERM=xterm
  '';

  users.users.${mainUser} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
    ];
  };

  # Important: for deploying without since we can't enter pasword with colmena
  security.sudo.extraRules = [
    {
      users = [mainUser];
      commands = [
        {
          command = "ALL";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
  nix.settings.trusted-users = [mainUser];

  environment.systemPackages = with pkgs; [
    ani-cli
    (pkgs.writeShellScriptBin "mount_zfs_pool" ''
      # Ask for the passphrase to unlock the LUKS-encrypted device
      echo -n "Enter the passphrase for /dev/sdb1: "
      read -s PASS

      # Open the LUKS volume
      echo "$PASS" | sudo ${pkgs.cryptsetup}/bin/cryptsetup open /dev/sdb1 zfs_crypt

      # Check if cryptsetup was successful
      if [ $? -ne 0 ]; then
      	echo "Failed to open LUKS device"
      	exit 1
      fi

      # Import the ZFS pool
      echo "Importing the ZFS pool 'datapool'..."
      sudo ${pkgs.zfs}/bin/zpool import datapool

      # Check if zpool import was successful
      if [ $? -ne 0 ]; then
      	echo "Failed to import ZFS pool"
      	exit 1
      fi

      echo "LUKS device unlocked and ZFS pool imported successfully."

    '')
  ];

  system.stateVersion = "24.11";

  # ZFS
  boot.supportedFilesystems = ["zfs"];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "54c7f0c1";

  # Minecraft

  topology.self.services = {
    nix-minecraft = {
      name = "Minecraft";
      icon = "services.minecraft"; # TODO create service extractor
      info = "Minecraft Server 1.21.1";
      details.listen.text = "mc.tolok.org";
    };
  };

  imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
  nixpkgs.overlays = [inputs.nix-minecraft.overlay];

  services.minecraft-servers = {
    enable = true;
    eula = true;
    openFirewall = true;
    servers.vanilla = {
      enable = true;
      jvmOpts = "-Xmx4G -Xms2G";
      serverProperties = {
        server-port = 25565;
        difficulty = 3;
        motd = "NixOS Minecraft server!";
      };

      # Specify the custom minecraft server package
      package = pkgs.minecraftServers.vanilla-1_21_1;
    };
  };
}
