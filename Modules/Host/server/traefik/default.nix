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
    ${pkgs.coreutils}/bin/chown traefik /var/lib/certificates/sso.tolok.org/private.key
  '';
in {
  options.modules.server.traefik = {
    enable = mkOption {
      description = "Enable Traefik Reverse Proxy service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      # Open Ports
      networking.firewall.allowedTCPPorts = [80 443];

      # Set Cloudflare API environment variable (CF_API_KEY, CF_API_EMAIL)
      systemd.services.traefik = {
        serviceConfig = {
          EnvironmentFile = config.sops.secrets.cloudflare_api_env.path;
        };
      };
      sops.secrets.cloudflare_api_env = {
        sopsFile = ../secrets.yaml;
      };

      # Traefik Service
      services.traefik = {
        enable = true;
        staticConfigOptions = {
          serversTransport.insecureSkipVerify = true;
          log.level = "INFO";
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
      };
    };
}
