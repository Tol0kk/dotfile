# TODO: create coturn services
{
  flake.nixosModules.coturn =
    {
      lib,
      config,
      pkgs,
      ...
    }:

    let
      cfg = config.modules.services.coturn;

      # primaryIPv4 = lib.findFirst (
      #   addr: addr.family == "ipv4" && !(lib.hasPrefix "127." addr.address)
      # ) null (lib.flatten (lib.mapAttrsToList (n: i: i.addresses) config.networking.interfaces));

      # publicConfig = {
      #   realm = cfg.domain;
      #   cert = "/var/lib/acme/${cfg.domain}/cert.pem";
      #   pkey = "/var/lib/acme/${cfg.domain}/key.pem";
      # };

      # localConfig = {
      #   listeningIp = "0.0.0.0";
      #   relayAddress = primaryIPv4.address;
      # };

    in
    {
      options.modules.services.coturn = {
        open = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Open coturn to the internet using a public domain.";
        };

        local = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Open coturn on the local network.";
        };

        domain = lib.mkOption {
          type = lib.types.str;
          default = config.modules.services.traefik.domain;
          description = "Public domain for the coturn server. Defaults to networking.domain.";
        };
      };

      config = lib.mkIf cfg.enable {
        services.coturn = lib.mkMerge [
          {
            enable = true;
            staticAuthSecretFile = config.sops.secrets."coturn/static-auth-secret".path;
            minPort = 49152;
            maxPort = 65535;
            listeningPort = 3478;
            tlsListeningPort = 5349;
          }
          # (lib.mkIf cfg.open publicConfig)
          # (lib.mkIf (cfg.local && primaryIPv4 != null) localConfig)
        ];

        networking.firewall.allowedTCPPorts = [
          3478
          5349
        ];
        networking.firewall.allowedUDPPorts = [
          3478
          5349
        ]
        ++ (lib.range config.services.coturn.minPort config.services.coturn.maxPort);
      };
    };
}
