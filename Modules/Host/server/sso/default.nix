{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.server.kanidm;
  serverDomain = config.modules.server.cloudflared.domain;
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
      # Make sure traefik module is options
      modules.server.traefik.enable = true;

      services.traefik = {
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

      systemd.services.kanidm = {
        wants = ["network-online.target" "traefik-dumper.service"];
        after = ["network-online.target" "traefik-dumper.service"];
      };

      services.kanidm = {
        enableServer = true;
        serverSettings = {
          origin = "https://${domain}";
          domain = domain;
          bindaddress = "127.0.0.1:8443";

          # Certs files created by traefik-dumper service
          tls_chain = "/var/lib/certificates/${domain}/public.crt";
          tls_key = "/var/lib/certificates/${domain}/private.key";
        };
      };
    };
}
