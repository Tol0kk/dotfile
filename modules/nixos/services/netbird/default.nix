# ╔══════════════════════════════════════════════════════════════════════════════╗
# ║  Netbird Module — Server (VPS) & Client (Nodes)                            ║
# ║                                                                            ║
# ║  Architecture:                                                             ║
# ║    VPS (server.enable = true)                                              ║
# ║      ├── management API (gRPC + HTTP)                                      ║
# ║      ├── signal server  (gRPC)                                             ║
# ║      ├── coturn TURN/STUN relay                                            ║
# ║      ├── dashboard (web UI)                                                ║
# ║      └── reverse proxy via Traefik (or Nginx)                              ║
# ║                                                                            ║
# ║    Nodes (client.enable = true)                                            ║
# ║      └── netbird client daemon → joins the mesh via management URL         ║
# ║                                                                            ║
# ║  Identity Provider:                                                        ║
# ║    Requires an external OIDC provider (Zitadel, Keycloak, Authentik,       ║
# ║    Auth0, etc.). Set server.oidcConfigEndpoint accordingly.                ║
# ║                                                                            ║
# ║  Usage — see bottom of file for example configurations.                    ║
# ╚══════════════════════════════════════════════════════════════════════════════╝
{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.netbird;
  traefikcfg = config.modules.services.traefik;

  # ── Derived values ────────────────────────────────────────────────────────
  serverDomain = cfg.server.domain; # e.g. "netbird.example.com"
  managementUrl = "https://${serverDomain}";
  managementPort = cfg.server.managementPort;
  signalPort = cfg.server.signalPort;
  dashboardPort = cfg.server.dashboardPort;

  # Firewall port sets
  serverTcpPorts = [
    80
    443
    3478
    10000
    33080
  ];
  serverUdpPorts = [
    3478
    5349
    33080
  ];
  turnPortRange = {
    from = cfg.server.turnMinPort;
    to = cfg.server.turnMaxPort;
  };
in
{
  # ╭──────────────────────────────────────────────────────────────────────────╮
  # │  Options                                                                 │
  # ╰──────────────────────────────────────────────────────────────────────────╯
  options.modules.services.netbird = {
    # ── Server role ─────────────────────────────────────────────────────────
    server = {
      enable = mkEnableOption "Netbird server stack (management, signal, coturn, dashboard)";

      domain = mkOption {
        type = types.str;
        default = "vpn.${traefikcfg.domain}";
      };

      oidcConfigEndpoint = mkOption {
        description = "OIDC discovery URL of your identity provider";
        type = types.str;
        example = "https://auth.example.com/.well-known/openid-configuration";
      };

      clientId = mkOption {
        description = "OIDC client ID (not secret — safe to store in Nix)";
        type = types.str;
        example = "abc123def456";
      };

      managementPort = mkOption {
        description = "Local listen port for the management API";
        type = types.port;
        default = 8011;
      };

      signalPort = mkOption {
        description = "Local listen port for the signal server";
        type = types.port;
        default = 8012;
      };

      dashboardPort = mkOption {
        description = "Local listen port for the dashboard (only when enableDashboard = true)";
        type = types.port;
        default = 8013;
      };

      enableDashboard = mkOption {
        description = "Whether to enable the Netbird web dashboard";
        type = types.bool;
        default = true;
      };

      turnMinPort = mkOption {
        description = "Start of the TURN relay UDP port range";
        type = types.port;
        default = 40000;
      };

      turnMaxPort = mkOption {
        description = "End of the TURN relay UDP port range";
        type = types.port;
        default = 40050;
      };

      # ── Secrets (paths to files — never store secrets in the Nix store) ──
      coturnPasswordFile = mkOption {
        description = "Path to file containing the COTURN password";
        type = types.path;
        example = "/run/secrets/netbird-coturn-password";
      };

      dataStoreEncryptionKeyFile = mkOption {
        description = "Path to file containing the data-store encryption key";
        type = types.path;
        example = "/run/secrets/netbird-datastore-key";
      };

      relaySecretFile = mkOption {
        description = "Path to file containing the relay shared secret";
        type = types.nullOr types.path;
        default = null;
        example = "/run/secrets/netbird-relay-secret";
      };

      idpClientSecretFile = mkOption {
        description = "Path to file containing the IDP management client secret (for user sync)";
        type = types.nullOr types.path;
        default = null;
        example = "/run/secrets/netbird-idp-client-secret";
      };

      idpManagerType = mkOption {
        description = "IDP manager type (zitadel, keycloak, authentik, auth0, none)";
        type = types.str;
        default = "none";
        example = "zitadel";
      };

      useTraefik = mkOption {
        description = "Use Traefik as reverse proxy (false = use the built-in Nginx proxy)";
        type = types.bool;
        default = true;
      };

      extraManagementSettings = mkOption {
        description = "Extra attrset merged into services.netbird.server.management.settings";
        type = types.attrs;
        default = { };
      };
    };

    # ── Client role ─────────────────────────────────────────────────────────
    client = {
      enable = mkEnableOption "Netbird client (joins an existing Netbird network)";

      managementUrl = mkOption {
        description = "URL of the Netbird management server to connect to";
        type = types.str;
        default = "";
        example = "https://netbird.example.com";
      };

      interface = mkOption {
        description = "WireGuard interface name";
        type = types.str;
        default = "nb0";
      };

      port = mkOption {
        description = "WireGuard listen port";
        type = types.port;
        default = 51820;
      };

      enableUI = mkOption {
        description = "Install the Netbird desktop / tray UI";
        type = types.bool;
        default = false;
      };

      extraClients = mkOption {
        description = "Additional named Netbird client instances (multi-tunnel)";
        type = types.attrsOf (
          types.submodule {
            options = {
              port = mkOption {
                type = types.port;
                default = 51821;
              };
              interface = mkOption {
                type = types.str;
                default = "nb1";
              };
              managementUrl = mkOption {
                type = types.str;
                default = "";
              };
            };
          }
        );
        default = { };
      };
    };
  };

  # ╭──────────────────────────────────────────────────────────────────────────╮
  # │  Config                                                                  │
  # ╰──────────────────────────────────────────────────────────────────────────╯
  config = mkMerge [
    # ════════════════════════════════════════════════════════════════════════
    #  SERVER
    # ════════════════════════════════════════════════════════════════════════
    (mkIf cfg.server.enable {
      # ── Topology / service catalogue (your custom module) ─────────────
      topology.self.services = {
        netbird-management = {
          name = "Netbird Management";
          info = mkForce "VPN management API";
          details.listen.text = mkForce "${serverDomain} (localhost:${toString managementPort})";
        };
        netbird-signal = {
          name = "Netbird Signal";
          info = mkForce "VPN signalling server";
          details.listen.text = mkForce "${serverDomain} (localhost:${toString signalPort})";
        };
      };

      # ── Kernel modules for in-kernel WireGuard ────────────────────────
      boot.kernelModules = [
        "wireguard"
        "tun"
      ];

      # ── Firewall ──────────────────────────────────────────────────────
      networking.firewall = {
        allowedTCPPorts = serverTcpPorts;
        allowedUDPPorts = serverUdpPorts;
        allowedUDPPortRanges = [ turnPortRange ];
      };

      # ── Netbird server stack ──────────────────────────────────────────
      services.netbird.server = {
        enable = true;
        domain = serverDomain;

        # -- Nginx built-in proxy (used when useTraefik = false) ---------
        enableNginx = !cfg.server.useTraefik;

        # -- COTURN -------------------------------------------------------
        coturn = {
          enable = true;
          domain = serverDomain;
          passwordFile = cfg.server.coturnPasswordFile;
        };

        # -- Signal server ------------------------------------------------
        signal = {
          enable = true;
          enableNginx = !cfg.server.useTraefik;
          domain = serverDomain;
        };

        # -- Dashboard (optional) -----------------------------------------
        dashboard = {
          enable = cfg.server.enableDashboard;
          enableNginx = !cfg.server.useTraefik && cfg.server.enableDashboard;
          domain = serverDomain;
          settings = {
            AUTH_AUTHORITY =
              let
                # Extract authority from OIDC endpoint (strip /.well-known/*)
                parts = builtins.split "/\\.well-known/.*" cfg.server.oidcConfigEndpoint;
              in
              builtins.head parts;
            AUTH_CLIENT_ID = cfg.server.clientId;
            AUTH_AUDIENCE = cfg.server.clientId;
          };
        };

        # -- Management API -----------------------------------------------
        management = {
          enable = true;
          enableNginx = !cfg.server.useTraefik;
          domain = serverDomain;
          turnDomain = serverDomain;
          singleAccountModeDomain = serverDomain;
          oidcConfigEndpoint = cfg.server.oidcConfigEndpoint;

          settings = mkMerge [
            {
              # Signal
              Signal.URI = "${serverDomain}:443";

              # Auth
              HttpConfig.AuthAudience = cfg.server.clientId;

              # IDP
              IdpManagerConfig = {
                ManagerType = cfg.server.idpManagerType;
                ClientConfig = {
                  ClientID = cfg.server.clientId;
                  ClientSecret = mkIf (cfg.server.idpClientSecretFile != null) {
                    _secret = cfg.server.idpClientSecretFile;
                  };
                };
              };

              # Device auth / PKCE flows
              DeviceAuthorizationFlow.ProviderConfig = {
                Audience = cfg.server.clientId;
                ClientID = cfg.server.clientId;
              };
              PKCEAuthorizationFlow.ProviderConfig = {
                Audience = cfg.server.clientId;
                ClientID = cfg.server.clientId;
              };

              # TURN
              TURNConfig = {
                Secret._secret = cfg.server.coturnPasswordFile;
                CredentialsTTL = "12h";
                TimeBasedCredentials = false;
                Turns = [
                  {
                    Password._secret = cfg.server.coturnPasswordFile;
                    Proto = "udp";
                    URI = "turn:${serverDomain}:3478";
                    Username = "netbird";
                  }
                ];
              };

              # Relay (optional)
              Relay = mkIf (cfg.server.relaySecretFile != null) {
                Addresses = [ "rels://${serverDomain}:33080" ];
                CredentialsTTL = "24h";
                Secret._secret = cfg.server.relaySecretFile;
              };

              # Encryption key
              DataStoreEncryptionKey._secret = cfg.server.dataStoreEncryptionKeyFile;
            }
            cfg.server.extraManagementSettings
          ];
        };
      };

      # ── Traefik dynamic config (when useTraefik = true) ───────────────
      services.traefik.dynamicConfigOptions = mkIf cfg.server.useTraefik {
        http = {
          # -- Services ---------------------------------------------------
          services = {
            netbird-management.loadBalancer.servers = [
              { url = "http://localhost:${toString managementPort}"; }
            ];
            netbird-signal.loadBalancer.servers = [
              { url = "h2c://localhost:${toString signalPort}"; }
            ];
          }
          // optionalAttrs cfg.server.enableDashboard {
            netbird-dashboard.loadBalancer.servers = [
              { url = "http://localhost:${toString dashboardPort}"; }
            ];
          };

          # -- Routers ----------------------------------------------------
          routers = {
            # Management API — gRPC + REST
            netbird-management = {
              entryPoints = [ "websecure" ];
              rule = "Host(`${serverDomain}`) && PathPrefix(`/api`, `/management.ManagementService/`)";
              service = "netbird-management";
              tls = traefikcfg.tlsConfig;
            };

            # Signal — gRPC
            netbird-signal = {
              entryPoints = [ "websecure" ];
              rule = "Host(`${serverDomain}`) && PathPrefix(`/signalexchange.SignalExchange/`)";
              service = "netbird-signal";
              tls = traefikcfg.tlsConfig;
            };
          }
          // optionalAttrs cfg.server.enableDashboard {
            # Dashboard — catch-all on the domain
            netbird-dashboard = {
              entryPoints = [ "websecure" ];
              rule = "Host(`${serverDomain}`)";
              service = "netbird-dashboard";
              tls = traefikcfg.tlsConfig;
              priority = 1; # lowest priority so API/signal match first
            };
          };
        };
      };

      # ── Nginx TLS (when using built-in nginx proxy) ───────────────────
      services.nginx.virtualHosts = mkIf (!cfg.server.useTraefik) {
        "${serverDomain}" = {
          enableACME = true;
          forceSSL = true;
        };
      };

      # ── systemd hardening for coturn secret loading ───────────────────
      systemd.services.coturn.serviceConfig = {
        LoadCredential = [ "password:${cfg.server.coturnPasswordFile}" ];
      };
    })

    # ════════════════════════════════════════════════════════════════════════
    #  CLIENT
    # ════════════════════════════════════════════════════════════════════════
    (mkIf cfg.client.enable {
      # ── Kernel modules ────────────────────────────────────────────────
      boot.kernelModules = [
        "wireguard"
        "tun"
      ];

      # ── Packages ──────────────────────────────────────────────────────
      environment.systemPackages = with pkgs; [ netbird ] ++ optional cfg.client.enableUI netbird-ui;

      # ── Netbird client service ────────────────────────────────────────
      services.netbird.enable = true;

      # Primary client instance
      services.netbird.clients.netbird = {
        port = cfg.client.port;
        interface = cfg.client.interface;
        name = "netbird";
        hardened = false;
        environment = mkIf (cfg.client.managementUrl != "") {
          NB_MANAGEMENT_URL = cfg.client.managementUrl;
          NB_ADMIN_URL = cfg.client.managementUrl;
        };
      };

      # Additional client instances (multi-network)
      # services.netbird.clients = mapAttrs (name: clientCfg: {
      #   port = clientCfg.port;
      #   interface = clientCfg.interface;
      #   name = name;
      #   hardened = false;
      #   environment = mkIf (clientCfg.managementUrl != "") {
      #     NB_MANAGEMENT_URL = clientCfg.managementUrl;
      #     NB_ADMIN_URL = clientCfg.managementUrl;
      #   };
      # }) cfg.client.extraClients;

      # ── UI daemon ─────────────────────────────────────────────────────
      services.netbird.ui.enable = cfg.client.enableUI;

      # ── Firewall ──────────────────────────────────────────────────────
      networking.firewall.allowedUDPPorts = [ cfg.client.port ];
    })
  ];
}
