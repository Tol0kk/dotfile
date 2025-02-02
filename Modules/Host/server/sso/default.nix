{
  lib,
  pkgs,
  config,
}:
with lib; let
  cfg = config.modules.server.kanidm;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "sso.${serverDomain}";
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
      # Cloudflare Tunnel (Reverse Proxy)
      services.cloudflared = {
        tunnels."${tunnelId}".ingress."${domain}" = {
          service = "http://localhost:8443";
        };
      };

      services.kanidm = {
        enableServer = true;
        serverSettings = {
          origin = "https://${domain}";
          domain = domain;
          bindaddress = "[::]:8443";

          # TODO place certs path
          # tls_chain = certs."${serverDomain}".cert;
          # tls_key = certs."${serverDomain}".key;

          # tls_chain = "/etc/letsencrypt/live/login.toloklab.com/fullchain.pem"
          # tls_key = "/etc/letsencrypt/live/login.toloklab.com/privkey.pem"
        };
      };
    };
}
