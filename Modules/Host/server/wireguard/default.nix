{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.wireguard;
  _serverDomain = config.modules.server.cloudflared.domain;
  _tunnelId = config.modules.server.cloudflared.tunnelId;
  _domain = "uptime.${serverDomain}";
in {
  options.modules.server.wireguard = {
    enable = mkOption {
      description = "Enable wireguard service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      sops.secrets.wg_server_private_key = {
        # From systemd.netdev(5) [WIREGUARD]
        owner = "systemd-network";
        mode = "0640";
        group = "root";
        sopsFile = ./secrets.yaml;
      };
      environment.systemPackages = with pkgs; [
        wireguard-tools
      ];
      networking.firewall.checkReversePath = "loose";

      networking.firewall.allowedUDPPorts = [51820];
      networking.useNetworkd = true;
      systemd.network = {
        enable = true;
        netdevs."50-wg0" = {
          netdevConfig = {
            Kind = "wireguard";
            Name = "wg0";
            MTUBytes = "1300";
          };
          wireguardConfig = {
            PrivateKeyFile = config.sops.secrets.wg_server_private_key.path;
            ListenPort = 51820;
          };

          # List of allowed peers.
          # Steps for adding a new peer:
          # - Generate keys for the client with: wg genkey | tee peer_privatekey | wg pubkey > peer_publickey
          # - Create add new peer to the list bellow with the needed information
          # - Use ./template.conf to create config for a client (ex peer.conf)
          # - Generate a QR code for the new peer: qrencode -t utf8 < peer.conf
          wireguardPeers = [
            {
              # Phone
              PublicKey = "FL2HOmYoixEPXgJi/Jp83CV/kAJFmjZTDR1FQgZQDC4=";
              # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
              AllowedIPs = ["10.100.0.2/32"];
            }
            {
              # Phone
              PublicKey = "c8HVPhnw96kI/7dWeFaemYnXw2uJbOcnof+kCKxASSs=";
              # List of IPs assigned to this peer within the tunnel subnet. Used to configure routing.
              AllowedIPs = ["10.100.0.3/32"];
            }
          ];
        };
        networks.wg0 = {
          matchConfig.Name = "wg0";
          # Determines the IP address and subnet of the server's end of the tunnel interface.
          address = ["10.100.0.1/24"];
          networkConfig = {
            IPMasquerade = "ipv4";
            IPv4Forwarding = true;
            IPv6Forwarding = true;
          };
        };
      };
    };
}
