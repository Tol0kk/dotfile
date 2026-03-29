{ self, ... }:
{
  flake.nixosModules.minecraft-gtnh =
    {
      pkgs,
      ...
    }:
    {
      imports = [
        self.nixosModules.podman
      ];

      networking.firewall = {
        enable = true;
        allowedTCPPorts = [ 25565 ];
        allowedUDPPorts = [ 24454 ];
      };

      virtualisation.oci-containers = {
        containers = {
          minecraft =
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
    };
}
