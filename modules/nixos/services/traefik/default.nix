{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.services.traefik;

  dump-cert =
    let
      kanidm_domain = config.modules.services.kanidm.server.domain;
    in
    pkgs.writeShellScriptBin "dump-cert" ''
      ${pkgs.traefik-certs-dumper}/bin/traefik-certs-dumper file --domain-subdir --crt-name public --key-name private --source /var/lib/traefik/acme.json --dest /var/lib/certificates/ --version v2
      ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/${kanidm_domain}/private.key
      ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/${kanidm_domain}/public.crt
    '';

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
    enable = mkOption {
      description = "Enable Traefik Reverse Proxy service";
      type = types.bool;
      default = false;
    };
    openFirewall = mkOption {
      description = "Open port in the firewall for Traefik (80,443)";
      type = types.bool;
      default = false;
    };
    domain = mkOption {
      description = "Root domain";
      type = types.str;
      default = "localhost";
    };
    api_env_path = mkOption {
      description = "Secret EnvironmentFile used by trafik to use cloudflare, (CF_API_KEY, CF_API_EMAIL, TRAEFIK_AUTH_CLIENT_SECRETS). This is used for acme challenge, this will also create the domain name if needed.";
      type = types.nullOr types.path;
      default = null;
    };
    certResolver = mkOption {
      description = "Certificat resolver, use self sign if null, need api_env_path if not null";
      type =
        with types;
        nullOr (enum [
          "letsencrypt"
        ]);
      default = null;
    };
    tlsConfig = mkOption {
      type = types.nullOr types.attrs;
      default = if cfg.certResolver != null then { inherit (cfg) certResolver; } else { };
      visible = false; # Hidden from documentation
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      traefik = {
        name = "Traefik";
        info = lib.mkForce "Reverse Proxy / MiddleWare";
        details = lib.mkForce { };
      };
    };

    systemd.services.traefik = {
      serviceConfig = {
      };
    };

    # Open Ports
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [
      80
      443
    ];

    # Traefik Service
    services.traefik = {
      package = mytraefik;
      enable = true;
      staticConfigOptions = {
        # Global Settings
        global = {
          checkNewVersion = false;
          sendAnonymousUsage = false;
        };
        accessLog = {
          addInternals = true;
          bufferingSize = 100;
          filters.statusCodes = [
            "200-299"
            "400-499"
            "500-599"
          ];
        };
        # entryPoints."metrics".address = ":8082";
        metrics.prometheus = {
          entryPoint = "metrics"; # Defined below
          addEntryPointsLabels = true;
          addRoutersLabels = true;
          addServicesLabels = true;
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
        serversTransport.insecureSkipVerify = true;
        log.level = "INFO";
        certificatesResolvers = {
          letsencrypt = lib.mkIf (cfg.certResolver == "letsencrypt") {
            acme = {
              email = "personal@tolok.org";
              storage = "/var/lib/traefik/acme.json";
              dnsChallenge = {
                provider = "cloudflare";
                resolvers = [ "1.1.1.1:53" ];
                delayBeforeCheck = "10s";
              };
            };
          };
        };

        # HTTP
        entryPoints.web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
            permanent = true;
          };
        };

        # HTTPS
        entryPoints.websecure = {
          address = ":443";
          http.tls = {
            certResolver = if cfg.certResolver != null then cfg.certResolver else null;
            domains = [
              {
                main = cfg.domain;
                sans = [ "*.${cfg.domain}" ];
              }
            ];
          };
        };

        entryPoints.metrics = {
          address = ":8082";
        };

        # Plugins
        experimental.localPlugins.traefik-oidc-auth = {
          modulename = "github.com/sevensolutions/traefik-oidc-auth";
        };
      };

      dynamicConfigOptions.http = {
        middlewares = {
          oidc-auth = {
            plugin.traefik-oidc-auth = {
              provider = {
                Url = "https://sso.tolok.org/oauth2/openid/traefik-auth";
                ClientId = "traefik-auth"; # System ID in Kanidm
                ClientSecretEnv = "TRAEFIK_AUTH_CLIENT_SECRETS"; # ClientSecret from Kanidm on the tarfik-auth service
                TokenValidation = "IdToken";
                UsePkce = true;
              };
              Scopes = [
                "openid"
                "profile"
              ];
            };
          };
        };
        # };

      };

    };
    # --- Systemd Service Hardening & Setup ---
    systemd.services.traefik = {
      preStart = ''
        mkdir -p /var/lib/traefik

        # Secure acme.json if it exists, or create it
        if [ ! -f /var/lib/traefik/acme.json ]; then
          touch /var/lib/traefik/acme.json
        fi
        chmod 600 /var/lib/traefik/acme.json

        # Link local plugins
        rm -rf /var/lib/traefik/plugins-local
        ln -sf ${config.services.traefik.package}/bin/plugins-local /var/lib/traefik/plugins-local
      '';

      # Unified Service Config
      serviceConfig = {
        EnvironmentFile = cfg.api_env_path;
        WorkingDirectory = "/var/lib/traefik";
        StateDirectory = "traefik"; # Systemd manages /var/lib/traefik ownership

        # Run dumper immediately after start to ensure certs are present
        ExecStartPost = "-+${dump-cert}/bin/dump-cert";

        # Hardening
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        CapabilityBoundingSet = [ "CAP_NET_BIND_SERVICE" ];
        ProtectSystem = "full";
        PrivateTmp = true;
      };
    };

    # --- Certificate Watcher & Dumper ---
    # Watches for changes in acme.json (renewals) and triggers the dump script
    systemd.paths.traefik-cert-watcher = {
      description = "Watch Traefik ACME JSON for changes";
      wantedBy = [ "multi-user.target" ];
      pathConfig.PathChanged = "/var/lib/traefik/acme.json";
    };

    systemd.services.traefik-cert-watcher = {
      description = "Dump Traefik certificates on change";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "-+${dump-cert}/bin/dump-cert";
      };
    };

    systemd.services.kanidm.serviceConfig = {
      # Run the cert dumper before starting kanidm each time
      ExecStartPre = "-+${dump-cert}/bin/dump-cert";
    };
  };
}
