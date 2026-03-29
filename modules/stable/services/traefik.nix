# TODO: create traefik services
{ self, ... }:
{
  flake.nixosModules.traefik =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      inherit (lib) mkIf types mkOption;
      pref = config.preferences;
    in
    {
      key = "nixosModules.traefik";
      options.modules.services.traefik = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };
      };

      imports = [
        self.nixosModules.oauth2-proxy
      ];

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          traefik = {
            name = "Traefik";
            info = lib.mkForce "Reverse Proxy / MiddleWare";
            details = lib.mkForce { };
          };
        };

        # ── Secrets for Traefik DNS challenges ────────────────────────────────────────────────
        systemd.services.traefik.serviceConfig = {
          EnvironmentFile = config.sops.secrets."cloudflare/api_env".path;
        };

        # ── Traefik NixOS service ────────────────────────────────────────────────
        services.traefik = {
          enable = true;

          # ── Global Configuration  ────────────────────────────────────────────────
          staticConfigOptions.global = {
            checkNewVersion = false;
            sendAnonymousUsage = false;
          };

          # ── Logs Configuration  ────────────────────────────────────────────────
          staticConfigOptions = {
            log.level = "INFO";
            accessLog = {
              addInternals = true;
              bufferingSize = 100;
              filters.statusCodes = [
                "200-299"
                "400-499"
                "500-599"
              ];
              format = "json";
              fields.headers.defaultMode = "keep";
            };

            # tracing.otlp = {
            #   TODO: Setup Tracing with Jaeger or GrafanaTempo
            #   Assuming you have a collector (like Jaeger/Tempo) on localhost:4318
            #   http = {
            #     endpoint = "http://localhost:4318/v1/traces";
            #   };
            #   0.0 = Trace 0% of requests (Disabled)
            #   1.0 = Trace 100% of requests (Debug mode)
            #   ampleRate = 0.1;
            # };
          };

          # ── HTTP "web" enrtyPoints ────────────────────────────────────────────────
          staticConfigOptions.entryPoints.web = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
              permanent = true;
            };
          };

          # ── HTTPS "websecure" ────────────────────────────────────────────────
          staticConfigOptions.entryPoints.websecure = {
            address = ":443";
            http.tls = {
              certResolver = "letsencrypt";
              domains = [
                (mkIf config.modules.services.traefik.public {
                  main = "local.${pref.topDomain}";
                  sans = [ "*.local.${pref.topDomain}" ];
                })
                {
                  main = pref.topDomain;
                  sans = [ "*.${pref.topDomain}" ];
                }
              ];
            };
          };
          staticConfigOptions.certificatesResolvers = {
            letsencrypt = {
              acme = {
                email = "personal@tolok.org";
                dnsChallenge = {
                  provider = "cloudflare";
                  resolvers = [ "1.1.1.1:53" ];
                  delayBeforeCheck = "10s";
                };
              };
            };
          };

          # -- Catchall Error Page
          dynamicConfigOptions.http = {
            routers.catchall = {
              rule = "HostRegexp(`^.+[.]${pref.topDomain}$`) || Host(`${pref.topDomain}`)";
              entryPoints = [ "websecure" ];
              priority = 1;
              service = "catchall-svc";
            };

            services.catchall-svc = {
              loadBalancer.servers = [
                { url = "http://127.0.0.1:8099"; }
              ];
            };
          };

          # -- OAuth Proxy Middlewares
          dynamicConfigOptions.http = {
            services.oauth2-proxy.loadBalancer.servers = [
              { url = "http://127.0.0.1:4180"; }
            ];

            # 2. Define the ForwardAuth Middleware
            middlewares.kanidm-auth.forwardAuth = {
              address = "http://127.0.0.1:4180/";
              # trustForwardHeader = true;
              # These headers will be passed to your protected backend applications
              authResponseHeaders = [
                "X-Auth-Request-User"
                "X-Auth-Request-Email"
                "X-Auth-Request-Preferred-Username"
                "Authorization"
              ];
            };
          };
        };

        # --- Hardening Traefik ---
        systemd.services.traefik.serviceConfig = {
          AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
          CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
          ProtectSystem = "full";
          PrivateTmp = true;
        };

        # --- Open Ports Traefik ---
        networking.firewall.allowedTCPPorts = lib.optionals pref.openFirewall [
          80
          443
        ];

        networking.networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        networking.resolvconf.useLocalResolver = true;

        services.nginx = {
          enable = true;
          virtualHosts."catchall" = {
            listen = [
              {
                addr = "127.0.0.1";
                port = 8099;
              }
            ];
            root = pkgs.writeTextDir "index.html" (builtins.readFile ./error.html);

            extraConfig = ''
              error_page 404 /index.html;
            '';

            locations."/" = {
              return = "404";
            };
          };
        };
      };

    };
}
