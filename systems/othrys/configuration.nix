{
  pkgs,
  config,
  libCustom,
  modulesPath,
  ...
}:
with libCustom;
{
  imports = [ "${modulesPath}/virtualisation/oci-common.nix" ];

  sops.secrets.cloudflare_api_env = {
    sopsFile = ./secrets.yaml;
  };

  sops.secrets.cloudflare_dyndns = {
    sopsFile = ./secrets.yaml;
  };

  sops.secrets.garage_rpc = {
    sopsFile = ./secrets.yaml;
  };

  sops.secrets.garage_admin = {
    sopsFile = ./secrets.yaml;
  };

  sops.secrets.s3_kanidm_db = {
    sopsFile = ./secrets.yaml;
  };

  sops.secrets.s3_restic_kanidm = {
    sopsFile = ./secrets.yaml;
  };

  # Modules
  # TODO move domain creation into a toplevel module config
  modules = {
    users = {
      gaia = enabled;
    };
    system = {
      sops.enable = true;
      sops.defaultSopsFile = ./secrets.yaml;
      ssh.enable = true;
      ssh.auto-start-sshd = true;
    };
    archetype.server = enabled;
    services = {
      prometheus-node-exporter = enabled;
      jellyfin = enabled;
      glance = enabled;
      # deluge = enabled;
      # restic = enabled;
      dyndns = {
        enable = true;
        api_env_path = config.sops.secrets.cloudflare_dyndns.path;
      };
      traefik = {
        enable = true;
        openFirewall = true;
        domain = "othrys.tolok.org";
        certResolver = "letsencrypt";
        api_env_path = config.sops.secrets.cloudflare_api_env.path;
      };
      garage = {
        enable = true;
        replicationMode = "none";
        dataDir = "/var/lib/garage/data";
        metaDir = "/var/lib/garage/meta";
        rpcSecretFile = config.sops.secrets.garage_rpc.path;
        adminTokenFile = config.sops.secrets.garage_admin.path;
      };
      kanidm.server = {
        enable = true;
        adminPasswordFile = config.sops.secrets.kanidm_admin_pswd.path;
        idmAdminPasswordFile = config.sops.secrets.kanidm_idm_admin_pswd.path;
      };
    };
  };

  services.restic.backups = {
    kanidm-db = {
      paths = [
        "/var/backup/kanidm"
      ];
      environmentFile = config.sops.secrets.s3_kanidm_db.path;
      passwordFile = config.sops.secrets.s3_restic_kanidm.path;
      extraBackupArgs = [
        "--tag kanidm"
      ];
      pruneOpts = [
        "--keep-daily 3"
        "--keep-weekly 7"
        "--keep-monthly 2"
        "--group-by tags"
      ];
      repository = "s3:s3.othrys.tolok.org/kanidm-db";
      initialize = true;
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/minecraft/gtnh/data 0777 root root -"
  ];

  virtualisation.podman.enable = true;
  virtualisation.podman.dockerSocket.enable = true;
  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      gtnh =
        let
          gtnhServerZip = pkgs.fetchurl {
            # IMPORTANT: Replace this with the actual direct download URL for the GTNH 2.8.2 server pack
            url = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.8.4_Server_Java_17-25.zip";
            hash = "sha256-pY13GgfdcHU13wFRkIV1U5gpbB6RODYS0tMv82mQwIw=";
          };
        in
        {
          image = "docker.io/itzg/minecraft-server:java25";
          ports = [ "25565:25565" ];
          volumes = [
            "/var/lib/minecraft/gtnh/data:/data"
            "${gtnhServerZip}:/server-files/gtnh-server.zip:ro"
          ];
          environment = {
            EULA = "TRUE";
            TYPE = "CUSTOM";
            GENERIC_PACK = "/server-files/gtnh-server.zip";
            SKIP_GENERIC_PACK_UPDATE_CHECK = "true";
            FORCE_REDOWNLOAD = "false";
            CUSTOM_SERVER = "https://github.com/GTNewHorizons/lwjgl3ify/releases/download/2.1.16/lwjgl3ify-2.1.16-forgePatches.jar";
            MEMORY = "16G";
            JVM_OPTS = "-Dfml.readTimeout=180 @java9args.txt";

            # Server Properties
            MOTD = "GT:New Horizons on Podman nixos";
            DIFFICULTY = "hard";
            ENABLE_COMMAND_BLOCK = "true";
            SPAWN_PROTECTION = "1";
            VIEW_DISTANCE = "12";
            MODE = "0";
            LEVEL_TYPE = "rwg";
            ALLOW_FLIGHT = "TRUE";
            DUMP_SERVER_PROPERTIES = "TRUE";
            CREATE_CONSOLE_IN_PIPE = "true";

            WHITELIST = ''
              TolokTir
              hettei
              AquaBx
            '';
            OPS = ''
              TolokTir
            '';
          };
        };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 25565 ];
    allowedUDPPorts = [ 24454 ];
  };

  services.traefik.dynamicConfigOptions = {
    http = {
      services.dockhand.loadBalancer.servers = [
        { url = "http://localhost:3000"; }
      ];
      routers.dockhand = {
        entryPoints = [ "websecure" ];
        rule = "Host(`dockhand.${config.modules.services.traefik.domain}`)";
        service = "dockhand";
      };
    };
  };

  # Optional: Information Given for generating systems topology
  topology.self = {
    name = "Othrys";
    hardware.info = "Ampere 4 OCPU | 24GB | 200GB";
  };

  # TODO: ???
  systemd.network.enable = true;
  systemd.network.networks.enP4p1s0 = {
    matchConfig.Name = "enP4p1s0";
    address = [ "192.168.1.48/24" ];
  };

  users.users.gaia = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.trusted-users = [ "gaia" ];

  environment.systemPackages = with pkgs; [
  ];

  system.stateVersion = "25.11";
}
