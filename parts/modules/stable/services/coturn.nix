{ self, ... }:
{
  flake.nixosModules.coturn =
    {
      lib,
      config,
      pkgs,
      ...
    }:

    let
      inherit (lib)
        types
        mkOption
        mkForce
        ;
      pref = config.preferences;
      cfg = config.modules.services.coturn;

      domain = "turn.${pref.topDomain}";
      ports = {
        stun = 3478; # Standard STUN/TURN port (TCP/UDP)
        turns = 5349; # Standard TLS STUN/TURN port (TCP/UDP)
        min = 49152; # Min relay port for UDP traffic
        max = 65535; # Max relay port for UDP traffic
      };
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.coturn = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
          description = "Whether to expose the Coturn server publicly";
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services.coturn = {
          icon = "${self}/assets/icons/coturn.svg";
          name = "Coturn";
          info = "STUN/TURN server";
          details = {
            Local.text = mkForce "localhost:${toString ports.stun}";
          }
          // lib.optionalAttrs cfg.public {
            Public.text = mkForce "${domain}:${toString ports.stun}";
          };
        };

        # ── Coturn Configuration ────────────────────────────────────────
        services.coturn = {
          enable = true;
          realm = domain;

          # Listening IPs and Ports
          listening-ips = [
            "0.0.0.0"
            "::"
          ];
          listening-port = ports.stun;
          tls-listening-port = ports.turns;

          # Relay Port Range (Crucial for TURN UDP traffic allocation)
          min-port = ports.min;
          max-port = ports.max;

          # Security & Authentication (Required for Matrix / Netbird)
          use-auth-secret = true;
          static-auth-secret-file = config.sops.secrets."coturn/auth-secret".path;

          # Performance and Security Flags
          extraConfig = ''
            # No-CLI for security (disables telnet admin interface)
            no-cli

            # Prevent local IP leakage/loops (don't relay to localhost/LAN)
            no-tcp-relay
            denied-peer-ip=10.0.0.0-10.255.255.255
            denied-peer-ip=192.168.0.0-192.168.255.255
            denied-peer-ip=172.16.0.0-172.31.255.255

            # Log settings
            log-file=/var/log/coturn/turnserver.log
            simple-log
          '';
        };

        # ── Firewall Rules ────────────────────────────────────────
        # Traefik usually handles HTTP/HTTPS, but STUN/TURN requires direct
        # TCP/UDP port mapping to the host, bypassing standard HTTP proxies.
        networking.firewall = lib.mkIf cfg.public {
          allowedTCPPorts = [
            ports.stun
            ports.turns
          ];
          allowedUDPPorts = [
            ports.stun
            ports.turns
          ];
          allowedUDPPortRanges = [
            {
              from = ports.min;
              to = ports.max;
            }
          ];
        };
        sops.secrets."coturn/auth-secret" = {
          owner = config.systemd.services.coturn.serviceConfig.User;
          group = config.systemd.services.coturn.serviceConfig.Group;
          mode = "0400";
        };
      };
    };
}
