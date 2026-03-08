# TODO: create traefik services
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

      # dump-cert =
      #   let
      #     kanidm_domain = config.modules.services.kanidm.server.domain;
      #   in
      #   pkgs.writeShellScriptBin "dump-cert" ''
      #     ${pkgs.traefik-certs-dumper}/bin/traefik-certs-dumper file --domain-subdir --crt-name public --key-name private --source /var/lib/traefik/acme.json --dest /var/lib/certificates/ --version v2
      #     ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/${kanidm_domain}/private.key
      #     ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/${kanidm_domain}/public.crt
      #   '';

      mytraefik =
        let
          oidc-auth_author = "sevensolutions";
          oidc-auth_name = "traefik-oidc-auth";
          oidc-auth_version = "0.17.0";
        in
        pkgs.traefik.overrideAttrs (oldAttrs: {
          postInstall =
            oldAttrs.postInstall or ''
              mkdir -p $out/bin/plugins-local/src/github.com/${oidc-auth_author}/
              cp -r ${
                pkgs.fetchFromGitHub {
                  owner = oidc-auth_author;
                  repo = oidc-auth_name;
                  rev = "refs/tags/v${oidc-auth_version}";
                  sha256 = "sha256-aVSnmNzRIJuSm0GzgKLKSgTvxbC6D7U7TuyMyR65QH8=";
                }
              } $out/bin/plugins-local/src/github.com/${oidc-auth_author}/${oidc-auth_name}
            '';
        });
    in
    {
      options.modules.services.traefik = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };
      };

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
          package = mytraefik;
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
              # List all your domains and wildcards under the same entrypoint
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

          # ── Metrics ────────────────────────────────────────────────
          # staticConfigOptions = {
          #   metrics.prometheus = {
          #     entryPoint = "metrics"; # Defined below
          #     addEntryPointsLabels = true;
          #     addRoutersLabels = true;
          #     addServicesLabels = true;
          #   };
          #   entryPoints.metrics = {
          #     address = ":8082";
          #   };
          # };

          # ── Plugin OICD ────────────────────────────────────────────────
          # staticConfigOptions.experimental.localPlugins.traefik-oidc-auth = {
          #   modulename = "github.com/sevensolutions/traefik-oidc-auth";
          # };
          # dynamicConfigOptions.http = {
          #   middlewares = {
          #     oidc-auth = {
          #       plugin.traefik-oidc-auth = {
          #         provider = {
          #           Url = "https://sso.tolok.org/oauth2/openid/traefik-auth";
          #           ClientId = "traefik-auth"; # System ID in Kanidm
          #           ClientSecretEnv = "TRAEFIK_AUTH_CLIENT_SECRETS"; # ClientSecret from Kanidm on the tarfik-auth service
          #           TokenValidation = "IdToken";
          #           UsePkce = true;
          #         };
          #         Scopes = [
          #           "openid"
          #           "profile"
          #         ];
          #       };
          #     };
          #   };
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

        # services.traefik.staticConfigOptions.certificatesResolvers.letsencrypt.acme.storage =
        #   "/var/lib/traefik/acme.json";
        # systemd.services.traefik = {
        #   preStart = ''
        #     mkdir -p /var/lib/traefik

        #     # Secure acme.json if it exists, or create it
        #     if [ ! -f /var/lib/traefik/acme.json ]; then
        #       touch /var/lib/traefik/acme.json
        #     fi
        #     chmod 600 /var/lib/traefik/acme.json

        #     # Link local plugins
        #     rm -rf /var/lib/traefik/plugins-local
        #     ln -sf ${config.services.traefik.package}/bin/plugins-local /var/lib/traefik/plugins-local
        #   '';

        #   # Unified Service Config
        #   serviceConfig = {
        #     WorkingDirectory = "/var/lib/traefik";
        #     StateDirectory = "traefik"; # Systemd manages /var/lib/traefik ownership
        #     # Run dumper immediately after start to ensure certs are present
        #     ExecStartPost = "-+${dump-cert}/bin/dump-cert";
        #   };
        # };

        # # --- Certificate Watcher & Dumper ---
        # # Watches for changes in acme.json (renewals) and triggers the dump script
        # systemd.paths.traefik-cert-watcher = {
        #   description = "Watch Traefik ACME JSON for changes";
        #   wantedBy = [ "multi-user.target" ];
        #   pathConfig.PathChanged = "/var/lib/traefik/acme.json";
        # };

        # systemd.services.traefik-cert-watcher = {
        #   description = "Dump Traefik certificates on change";
        #   serviceConfig = {
        #     Type = "oneshot";
        #     ExecStart = "-+${dump-cert}/bin/dump-cert";
        #   };
        # };

        # systemd.services.kanidm.serviceConfig = {
        #   # Run the cert dumper before starting kanidm each time
        #   ExecStartPre = "-+${dump-cert}/bin/dump-cert";
        # };
        networking.networkmanager = {
          enable = true;
          dns = "systemd-resolved";
        };
        networking.resolvconf.useLocalResolver = true;
      };

    };
}
