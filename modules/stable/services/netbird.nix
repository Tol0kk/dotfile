{ self, ... }:
let
  mkPublic = pref: {
    dashboard = "netbird.${pref.topDomain}";
    api = "api.netbird.${pref.topDomain}";
    signal = "signal.netbird.${pref.topDomain}";
    relay = "relay.netbird.${pref.topDomain}";
  };

  ports = {
    dashboard = 11112;
    management = 33073;
    signal = 10000;
    relay = 33080;
  };
in
{
  flake.nixosModules.netbird-client =
    {
      lib,
      config,
      pkgs-unstable,
      pkgs,
      ...
    }:
    let
      public = mkPublic config.preferences;
    in
    {
      services.resolved.enable = true;
      # ── Netbird Client ────────────────────────────────────────────────────────
      services.netbird.clients.default = {
        port = 51820;
        openFirewall = true;
        autoStart = true;
        hardened = true;

        environment = {
          NB_MANAGEMENT_URL = "https://${config.preferences.netbird-api}:443";
        };

        login = {
          enable = true;
          setupKeyFile = config.sops.secrets."netbird/setup-key".path;
        };
      };

      # ── SOPS Secrets ────────────────────────────────────────────────────────

      # Setup key from netbird daskboard one time usage.
      sops.secrets."netbird/setup-key" = { };
    };
  flake.nixosModules.netbird-server =
    {
      lib,
      config,
      pkgs,
      pkgs-unstable,
      ...
    }:
    let
      inherit (lib) mkForce;
      pref = config.preferences;
      public = mkPublic pref;
    in
    {
      config = {
        # ── Topology / Service Catalogue ────────────────────────────────────────
        topology.self.services = {
          netbird-dashboard = {
            icon = "${self}/assets/icons/netbird.svg";
            name = "Netbird Dashboard";
            info = "Web UI for Netbird VPN";
            details = {
              Public.text = mkForce "${public.dashboard}";
            };
          };
          netbird-management = {
            icon = "${self}/assets/icons/netbird.svg";
            name = "Netbird Management";
            info = "API & peer coordination";
            details = {
              Public.text = mkForce "${public.api}";
            };
          };
          netbird-signal = {
            icon = "${self}/assets/icons/netbird.svg";
            name = "Netbird Signal";
            info = "WebRTC signaling server";
            details = {
              Public.text = mkForce "${public.signal}";
            };
          };
        };

        preferences.netbird-api = lib.mkDefault public.api;

        # ── Traefik Configuration ───────────────────────────────────────────────
        services.traefik.dynamicConfigOptions.http = {
          routers = {
            netbird-management-grpc = {
              rule = "Host(`${public.api}`) && (PathPrefix(`/management.ManagementService/`) || PathPrefix(`/management.ProxyService/`))";
              entryPoints = [ "websecure" ];
              service = "netbird-management-grpc";
              tls.certResolver = "letsencrypt";
            };
            # WebSocket + REST + OAuth2 → plain http backend (HTTP/1.1, handles WS upgrade)
            netbird-management-http = {
              rule = "Host(`${public.api}`) && (PathPrefix(`/ws-proxy/`) || PathPrefix(`/api`) || PathPrefix(`/oauth2`) || PathPrefix(`/auth`))";
              entryPoints = [ "websecure" ];
              service = "netbird-management-http";
              tls.certResolver = "letsencrypt";
            };
            netbird-signal = {
              rule = "Host(`${public.signal}`)";
              entryPoints = [ "websecure" ];
              service = "netbird-signal";
              tls.certResolver = "letsencrypt";
            };
            netbird-relay = {
              rule = "Host(`${public.relay}`)";
              entryPoints = [ "websecure" ];
              service = "netbird-relay";
              tls.certResolver = "letsencrypt";
            };
          };

          services = {
            # Management is gRPC h2c
            netbird-management-grpc.loadBalancer = {
              servers = [ { url = "h2c://127.0.0.1:${toString ports.management}"; } ];
              passHostHeader = true;
              responseForwarding.flushInterval = "1ms";
            };
            netbird-management-http.loadBalancer = {
              servers = [ { url = "http://127.0.0.1:${toString ports.management}"; } ];
              passHostHeader = true;
              responseForwarding.flushInterval = "1ms";
            };
            netbird-relay.loadBalancer = {
              servers = [ { url = "http://127.0.0.1:${toString ports.relay}"; } ];
              passHostHeader = true;
              responseForwarding.flushInterval = "1ms";
            };
            # Signal fronts gRPC with an HTTP/WebSocket server — use plain http,
            # let Traefik negotiate the WebSocket upgrade the stream needs
            netbird-signal.loadBalancer = {
              servers = [
                { url = "h2c://127.0.0.1:${toString ports.signal}"; }
              ];
              passHostHeader = true;
              responseForwarding.flushInterval = "1ms";
            };
          };
        };

        services.nginx.virtualHosts.${public.dashboard}.listen = [
          {
            addr = "127.0.0.1";
            port = ports.dashboard;
          }
        ];
        services.traefik.dynamicConfigOptions.http = {
          routers.netbird-dashboard = {
            rule = "Host(`${public.dashboard}`)";
            entryPoints = [ "websecure" ];
            service = "netbird-dashboard";
            tls.certResolver = "letsencrypt";
          };
          services.netbird-dashboard.loadBalancer.servers = [
            { url = "http://127.0.0.1:${toString ports.dashboard}"; }
          ];
        };

        # ── Netbird Server Components ───────────────────────────────────────────

        services.netbird.server.management = {
          enable = true;
          package = pkgs-unstable.netbird-management;
          port = ports.management;
          domain = pref.topDomain;

          turnDomain = "turn.${pref.topDomain}";

          oidcConfigEndpoint = "https://auth.${pref.topDomain}/oauth2/openid/netbird/.well-known/openid-configuration";

          settings = {
            DataStoreEncryptionKey = {
              _secret = config.sops.secrets."netbird/datastore-key".path;
            };

            HttpConfig = {
              AuthOIDCPath = "/auth";
              AuthIssuer = "https://auth.${pref.topDomain}/oauth2/openid/netbird";
              AuthAudience = "netbird";
            };

            TURNConfig = {
              Turns = [
                {
                  Proto = "udp";
                  URI = "turn:turn.${pref.topDomain}:3478";
                  Username = "netbird";
                }
              ];
              Secret = {
                _secret = config.sops.secrets."coturn/auth-secret".path;
              };
            };
            Signal = {
              Proto = "https";
              URI = "signal.netbird.${pref.topDomain}:10443";
            };

            IdpManagerConfig = {
              ManagerType = "none";
            };

            Relay = {
              Addresses = [ "rels://${public.relay}:443" ];
              Secret = {
                _secret = config.sops.secrets."netbird/relay-secret".path;
              };
              CredentialsTTL = "24h";
            };
          };
        };

        services.traefik.staticConfigOptions.entryPoints.signal = {
          address = ":10443";
        };

        # TCP router with TLS termination, L4 forward to signal
        services.traefik.dynamicConfigOptions.tcp = {
          routers.netbird-signal = {
            entryPoints = [ "signal" ];
            rule = "HostSNI(`${public.signal}`)";
            service = "netbird-signal";
            tls.certResolver = "letsencrypt";
          };
          services.netbird-signal.loadBalancer.servers = [
            { address = "127.0.0.1:${toString ports.signal}"; }
          ];
        };

        networking.firewall.allowedTCPPorts = [ 10443 ];

        services.netbird.server.signal = {
          enable = true;
          package = pkgs-unstable.netbird-signal;
          port = ports.signal;
        };

        services.netbird.server.dashboard = {
          enable = true;
          package = pkgs-unstable.netbird-dashboard;
          enableNginx = true;
          domain = public.dashboard; # "netbird.${pref.topDomain}"
          managementServer = "https://${public.api}";
          settings = {
            AUTH_AUTHORITY = "https://auth.${pref.topDomain}/oauth2/openid/netbird";
            AUTH_CLIENT_ID = "netbird";
            AUTH_AUDIENCE = "netbird";
            AUTH_SUPPORTED_SCOPES = "openid profile email";
            AUTH_REDIRECT_URI = "/callback";
            AUTH_SILENT_REDIRECT_URI = "/silent-auth";
          };
        };

        systemd.services.netbird-relay = {
          description = "NetBird WebSocket relay (rels://)";
          wantedBy = [ "multi-user.target" ];
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          serviceConfig = {
            ExecStart = ''
              ${pkgs.bash}/bin/bash -c '${lib.getExe' pkgs-unstable.netbird-relay "netbird-relay"} \
                --exposed-address rels://${public.relay}:443 \
                --listen-address 127.0.0.1:${toString ports.relay} \
                --metrics-port 9092 \
                --health-listen-address 127.0.0.1:9001 \
                --auth-secret "$NB_AUTH_SECRET"'
            '';
            EnvironmentFile = config.sops.templates."netbird-relay.env".path;
            DynamicUser = true;
            Restart = "on-failure";
            RestartSec = 5;
          };
        };

        # ── SOPS Secrets ────────────────────────────────────────────────────────
        sops.secrets."coturn/auth-secret" = {
          owner = mkForce "root";
          group = mkForce "root";
          mode = mkForce "0444";
        };

        sops.secrets."netbird/datastore-key" = {
          mode = "0400";
        };

        sops.templates."netbird-relay.env" = {
          content = ''
            NB_AUTH_SECRET=${config.sops.placeholder."netbird/relay-secret"}
          '';
          mode = "0444";
        };
        sops.secrets."netbird/relay-secret" = { };

        # ── prometheus scrapeConfigs ────────────────────────────────────────────────────────
        services.prometheus.scrapeConfigs =
          lib.mapAttrsToList
            (job: target: {
              job_name = job;
              static_configs = [
                {
                  targets = [ target ];
                  labels.instance = config.networking.hostName;
                }
              ];
            })
            {
              netbird-management = "127.0.0.1:9090";
              netbird-signal = "127.0.0.1:9091";
              netbird-relay = "127.0.0.1:9092";
            };
      };
    };
}
