{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.server.kanidm;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "sso.${serverDomain}";

  dump-cert = pkgs.writeShellScriptBin "dump-cert" ''
    ${pkgs.traefik-certs-dumper}/bin/traefik-certs-dumper file --domain-subdir --crt-name public --key-name private --source /var/lib/traefik/acme.json --dest /var/lib/certificates/ --version v2
    ${pkgs.coreutils}/bin/chown kanidm /var/lib/certificates/sso.tolok.org/private.key
  '';
in {
  options.modules.server.kanidm = {
    enable = mkOption {
      description = "Enable Kanidm service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      networking.firewall.allowedTCPPorts = [80 443];
      # Standalone
      systemd.services.traefik = {
        serviceConfig = {
          EnvironmentFile = config.sops.secrets.cloudflare_api_env.path;
        };
      };

      sops.secrets.cloudflare_api_env = {
        sopsFile = ../secrets.yaml;
      };

      services.traefik = {
        # Standalone
        enable = true;
        staticConfigOptions = {
          serversTransport.insecureSkipVerify = true;
          log.level = "DEBUG";
          accessLog = {};
          certificatesResolvers = {
            # vpn.tailscale = {};
            letsencrypt = {
              acme = {
                email = "titouanledilavrec@gmail.com";
                storage = "/var/lib/traefik/acme.json";
                dnsChallenge = {
                  provider = "cloudflare";
                };
              };
            };
          };
          entryPoints.web = {
            address = "0.0.0.0:80";
            http.redirections.entryPoint = {
              to = "websecure";
              scheme = "https";
              permanent = true;
            };
          };
          entryPoints.websecure = {
            address = "0.0.0.0:443";
            http.tls.domains = [
              {
                main = "tolok.org";
                sans = ["*.tolok.org"];
              }
            ];
            http.tls.certResolver = "letsencrypt";
          };
        };

        # Kanidm Configuration
        dynamicConfigOptions = {
          http = {
            services.Kanidm.loadBalancer.servers = [
              {
                url = "https://127.0.0.1:8443";
              }
            ];

            routers.Kanidm = {
              entryPoints = ["websecure"];
              rule = "Host(`${domain}`)";
              service = "Kanidm";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };

      # Traefik certs dumper

      systemd.services.traefik-dumper = {
        enable = true;
        path = [pkgs.getent pkgs.traefik-certs-dumper];
        serviceConfig = {
          ExecStart = "${dump-cert}/bin/dump-cert";
        };
        wantedBy = ["multi-user.target"];
        after = [
          "traefik.service"
        ];
        before = [
          "kanidm-unixd.service"
          "kanidm.service"
        ];
      };

      services.kanidm = {
        enableServer = true;
        serverSettings = {
          origin = "https://${domain}";
          domain = domain;
          bindaddress = "127.0.0.1:8443";

          # TODO place certs path
          # tls_chain = certs."${serverDomain}".cert;
          # tls_key = certs."${serverDomain}".key;

          tls_chain = "/var/lib/certificates/${domain}/public.crt";
          tls_key = "/var/lib/certificates/${domain}/private.key";
        };
      };
    };
}
