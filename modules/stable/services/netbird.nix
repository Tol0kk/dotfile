{ self, ... }:
let
  mkPublic = pref: {
    dashboard = "netbird.${pref.topDomain}";
    api = "api.netbird.${pref.topDomain}";
    signal = "signal.netbird.${pref.topDomain}";
  };

  ports = {
    dashboard = 11112;
    management = 33073;
    signal = 10000;
  };
in
{
  flake.nixosModules.netbird-client =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      public = mkPublic config.preferences;
    in
    {
      # ── Netbird Client ────────────────────────────────────────────────────────
      services.netbird.clients.default = {
        port = 51820;
        openFirewall = true;
        autoStart = true;
        hardened = true;

        environment = {
          NB_MANAGEMENT_URL = "https://${public.api}";
        };

        login = {
          enable = true;
          setupKeyFile = config.sops.secrets."netbird/setup-key".path;
          systemdDependencies = [
            "sops-install-secrets.service" # ensure the key file exists first
          ];
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

        # ── Traefik Configuration ───────────────────────────────────────────────
        services.traefik.dynamicConfigOptions.http = {
          routers = {
            netbird-management = {
              rule = "Host(`${public.api}`)";
              entryPoints = [ "websecure" ];
              service = "netbird-management";
              tls.certResolver = "letsencrypt";
            };
            netbird-signal = {
              rule = "Host(`${public.signal}`)";
              entryPoints = [ "websecure" ];
              service = "netbird-signal";
              tls.certResolver = "letsencrypt";
            };
          };

          services = {
            # Management is gRPC h2c
            netbird-management.loadBalancer.servers = [
              { url = "h2c://127.0.0.1:${toString ports.management}"; }
            ];
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
          port = ports.signal;
        };

        services.netbird.server.dashboard = {
          enable = true;
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

        # ── SOPS Secrets ────────────────────────────────────────────────────────
        sops.secrets."coturn/auth-secret" = {
          owner = mkForce "root";
          group = mkForce "root";
          mode = mkForce "0444";
        };

        sops.secrets."netbird/datastore-key" = {
          mode = "0400";
        };
      };
    };
}
