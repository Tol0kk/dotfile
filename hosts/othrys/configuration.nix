{
  self,
  modulesPath,
  ...
}:
{
  # ── Topology / service catalogue ────────────────────────────────────────
  topology.self = {
    name = "Othrys";
    hardware.info = "Ampere 4 OCPU | 24GB | 200GB";
  };

  # ── Modules Imports ────────────────────────────────────────
  imports = [
    "${modulesPath}/virtualisation/oci-common.nix"

    # Archetype
    self.nixosModules.server # This import traefik modules
    self.nixosModules.gaia

    # Services
    self.nixosModules.prometheus-node-exporter
    self.nixosModules.glance
    self.nixosModules.dyndns
    self.nixosModules.kanidm-server
    self.nixosModules.garage
    self.nixosModules.coturn
    self.nixosModules.forgejo
    # self.nixosModules.netbird
    self.nixosModules.searxng

    self.nixosModules.minecraft-gtnh

  ];

  # ── Globals Preferences ────────────────────────────────────────
  preferences = {
    topDomain = "othrys.tolok.org";
    openFirewall = true;
    public = true;
  };

  # ── Secrets Declaration ────────────────────────────────────────
  sops.secrets."cloudflare/api_env" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."cloudflare/dyndns" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."garage/admin" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."garage/rpc" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."kanidm/idm_admin" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."kanidm/s3" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."restic/kanidm" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."forgejo/admin-env" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."coturn/auth-secret" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."netbird/idp-secret" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."netbird/datastore-key" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."searxng/env" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."oauth2_proxy/clientSecret" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."oauth2_proxy/secretSeed" = {
    sopsFile = ./secrets.yaml;
  };

  # ── Modules Settings ────────────────────────────────────────

  modules.services = {
    prometheus-node-exporter.public = false;
  };

  # ── Miscs ────────────────────────────────────────

  # services.restic.backups = {
  #   kanidm-db = {
  #     paths = [
  #       "/var/backup/kanidm"
  #     ];
  #     environmentFile = config.sops.secrets.s3_kanidm_db.path;
  #     passwordFile = config.sops.secrets.s3_restic_kanidm.path;
  #     extraBackupArgs = [
  #       "--tag kanidm"
  #     ];
  #     pruneOpts = [
  #       "--keep-daily 3"
  #       "--keep-weekly 7"
  #       "--keep-monthly 2"
  #       "--group-by tags"
  #     ];
  #     repository = "s3:s3.othrys.tolok.org/kanidm-db";
  #     initialize = true;
  #   };
  # };

  # systemd.tmpfiles.rules = [
  #   "d /var/lib/minecraft/gtnh/data 0777 root root -"
  # ];

  # virtualisation.podman.enable = true;
  # virtualisation.podman.dockerSocket.enable = true;
  # virtualisation.oci-containers = {
  #   backend = "podman";
  #   containers = {
  #     gtnh =
  #       let
  #         gtnhServerZip = pkgs.fetchurl {
  #           # IMPORTANT: Replace this with the actual direct download URL for the GTNH 2.8.2 server pack
  #           url = "https://downloads.gtnewhorizons.com/ServerPacks/GT_New_Horizons_2.8.4_Server_Java_17-25.zip";
  #           hash = "sha256-pY13GgfdcHU13wFRkIV1U5gpbB6RODYS0tMv82mQwIw=";
  #         };
  #       in
  #       {
  #         image = "docker.io/itzg/minecraft-server:java25";
  #         ports = [ "25565:25565" ];
  #         volumes = [
  #           "/var/lib/minecraft/gtnh/data:/data"
  #           "${gtnhServerZip}:/server-files/gtnh-server.zip:ro"
  #         ];
  #         environment = {
  #           EULA = "TRUE";
  #           TYPE = "CUSTOM";
  #           GENERIC_PACK = "/server-files/gtnh-server.zip";
  #           SKIP_GENERIC_PACK_UPDATE_CHECK = "true";
  #           FORCE_REDOWNLOAD = "false";
  #           CUSTOM_SERVER = "https://github.com/GTNewHorizons/lwjgl3ify/releases/download/2.1.16/lwjgl3ify-2.1.16-forgePatches.jar";
  #           MEMORY = "16G";
  #           JVM_OPTS = "-Dfml.readTimeout=180 @java9args.txt";

  #           # Server Properties
  #           MOTD = "GT:New Horizons on Podman nixos";
  #           DIFFICULTY = "hard";
  #           ENABLE_COMMAND_BLOCK = "true";
  #           SPAWN_PROTECTION = "1";
  #           VIEW_DISTANCE = "12";
  #           MODE = "0";
  #           LEVEL_TYPE = "rwg";
  #           ALLOW_FLIGHT = "TRUE";
  #           DUMP_SERVER_PROPERTIES = "TRUE";
  #           CREATE_CONSOLE_IN_PIPE = "true";

  #           WHITELIST = ''
  #             TolokTir
  #             hettei
  #             AquaBx
  #           '';
  #           OPS = ''
  #             TolokTir
  #           '';
  #         };
  #       };
  #   };
  # };

  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ 25565 ];
  #   allowedUDPPorts = [ 24454 ];
  # };

  # services.traefik.dynamicConfigOptions = {
  #   http = {
  #     services.dockhand.loadBalancer.servers = [
  #       { url = "http://localhost:3000"; }
  #     ];
  #     routers.dockhand = {
  #       entryPoints = [ "websecure" ];
  #       rule = "Host(`dockhand.${config.modules.services.traefik.domain}`)";
  #       service = "dockhand";
  #     };
  #   };
  # };

  # # TODO: ???
  # systemd.network.enable = true;
  # systemd.network.networks.enP4p1s0 = {
  #   matchConfig.Name = "enP4p1s0";
  #   address = [ "192.168.1.48/24" ];
  # };

  security.sudo.wheelNeedsPassword = false;
}
