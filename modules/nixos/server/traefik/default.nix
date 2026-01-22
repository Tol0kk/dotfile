{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.server.traefik;
  serverDomain = config.modules.server.cloudflared.domain;

  dump-cert = pkgs.writeShellScriptBin "dump-cert" ''
    ${pkgs.traefik-certs-dumper}/bin/traefik-certs-dumper file --domain-subdir --crt-name public --key-name private --source /var/lib/traefik/acme.json --dest /var/lib/certificates/ --version v2
    ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/sso.tolok.org/private.key
    ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/sso.tolok.org/public.crt
  '';

  mytraefik = let
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
in {
  options.modules.server.traefik = {
    enable = mkOption {
      description = "Enable Traefik Reverse Proxy service";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      traefik = {
        name = "Traefik";
        info = lib.mkForce "Reverse Proxy / MiddleWare";
        details = lib.mkForce {};
      };
    };

    # Open Ports
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # Set Cloudflare API environment variable (CF_API_KEY, CF_API_EMAIL, TRAEFIK_AUTH_CLIENT_SECRETS)
    systemd.services.traefik = {
      serviceConfig = {
        EnvironmentFile = config.sops.secrets.cloudflare_api_env.path;
        # WorkingDirectory = "${config.services.traefik.package}/bin";
      };
    };
    sops.secrets.cloudflare_api_env = {
      sopsFile = ../secrets.yaml;
    };

    # Traefik Service
    services.traefik = {
      package = mytraefik;
      enable = true;
      staticConfigOptions = {
        serversTransport.insecureSkipVerify = true;
        accessLog = {
          addInternals = true;
        };
        # log.level = "TRACE";
        # Add Prometheus support
        entryPoints."metrics".address = ":8082";
        metrics.prometheus = {
          entryPoint = "metrics";
          addEntryPointsLabels = true;
          addRoutersLabels = true;
        };
        certificatesResolvers = {
          # vpn.tailscale = {};

          letsencrypt = {
            acme = {
              email = "personal@tolok.org";
              storage = "/var/lib/traefik/acme.json";
              dnsChallenge = {
                provider = "cloudflare";
              };
            };
          };
        };
        experimental = {
          localPlugins = {
            # Plugin to use OIDC as traefik auth system
            traefik-oidc-auth = {
              modulename = "github.com/sevensolutions/traefik-oidc-auth";
              # local is without version
            };
          };
        };
        entryPoints.web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
            permanent = true;
          };
        };
        entryPoints.websecure = {
          address = ":443";
          http.tls.domains = [
            {
              main = "tolok.org";
              sans = ["*.tolok.org"];
            }
          ];
          http.tls.certResolver = "letsencrypt";
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
      };
    };

    # Traefik certs dumper
    systemd.services.traefik-dumper = {
      enable = true;
      path = [
        pkgs.getent
        pkgs.traefik-certs-dumper
      ];
      serviceConfig = {
        ExecStart = "${dump-cert}/bin/dump-cert";
      };
      wantedBy = ["multi-user.target"];
      partOf = ["traefik.service"];
      after = [
        "traefik.service"
      ];
    };
  };
}
