{ self, ... }:
{
  flake.nixosModules.netbird =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkForce;
      pref = config.preferences;

      public = {
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
      config = {
        # ── Topology / Service Catalogue ────────────────────────────────────────
        topology.self.services = {
          # netbird-dashboard = {
          #   name = "Netbird Dashboard";
          #   info = "Web UI for Netbird VPN";
          #   details = {
          #     Public.text = mkForce "${public.dashboard}";
          #   };
          # };
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
            # netbird-dashboard = {
            #   rule = "Host(`${public.dashboard}`)";
            #   entryPoints = [ "websecure" ];
            #   service = "netbird-dashboard";
            #   tls.certResolver = "letsencrypt";
            # };
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
            # netbird-dashboard.loadBalancer.servers = [
            #   { url = "http://127.0.0.1:${toString ports.dashboard}"; }
            # ];
            # Management and Signal require gRPC (h2c) in addition to standard HTTP
            netbird-management.loadBalancer.servers = [
              { url = "h2c://127.0.0.1:${toString ports.management}"; }
            ];
            netbird-signal.loadBalancer.servers = [
              { url = "h2c://127.0.0.1:${toString ports.signal}"; }
            ];
          };
        };

        # ── Netbird Server Components ───────────────────────────────────────────

        # 1. Management Service
        services.netbird.server.management = {
          enable = true;
          port = ports.management;
          domain = pref.topDomain;

          oidcConfigEndpoint = "https://auth.${pref.topDomain}/.well-known/openid-configuration";
          turnDomain = "turn.${pref.topDomain}";

          settings = {
            DataStoreEncryptionKey = {
              _secret = config.sops.secrets."netbird/datastore-key".path;
            };

            HttpConfig = {
              AuthOIDCPath = "/auth";
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

            IdpManagerConfig = {
              ManagerType = "zitadel";
              ClientConfig = {
                Issuer = "https://auth.${pref.topDomain}";
                ClientID = "netbird-management";
                ClientSecret = {
                  _secret = config.sops.secrets."netbird/idp-secret".path;
                };
              };
            };
          };
        };

        # 2. Signal Service
        services.netbird.server.signal = {
          enable = true;
          port = ports.signal;
        };

        # 3. Dashboard Web UI
        services.netbird.server.dashboard = {
          enable = true;
          # port = ports.dashboard;
          managementServer = "https://${public.api}";

          settings = {
            NETBIRD_MGMT_API_ENDPOINT = "https://${public.api}";
            NETBIRD_MGMT_GRPC_API_ENDPOINT = "https://${public.api}";
            AUTH_AUTHORITY = "https://auth.${pref.topDomain}";
            AUTH_CLIENT_ID = "netbird-dashboard";
            AUTH_SUPPORTED_SCOPES = "openid profile email offline_access api";
          };
        };

        # ── SOPS Secrets ────────────────────────────────────────────────────────
        sops.secrets."coturn/auth-secret" = {
          owner = mkForce "root";
          group = mkForce "root";
          mode = mkForce "0444";
        };

        sops.secrets."netbird/idp-secret" = {
          mode = "0400";
        };

        sops.secrets."netbird/datastore-key" = {
          mode = "0400";
        };
      };
    };
}
