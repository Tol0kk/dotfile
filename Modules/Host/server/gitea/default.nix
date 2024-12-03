{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.server.gitea;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "git.${serverDomain}";
in
{
  options.modules.server.gitea = {
    enable = mkOption {
      description = "Enable Gitea services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {

    # Cloudflare Tunnel (Reverse Proxy)
    services.cloudflared = {
      tunnels."${tunnelId}".ingress."${domain}" = {
        service = "http://localhost:3001";
      };
    };

    # Postgress (Store Gitea data)
    services.postgresql = {
      enable = true; # Ensure postgresql is enabled
      ensureDatabases = [ config.services.gitea.user ];
      ensureUsers = [
        {
          name = config.services.gitea.database.user;
          ensureDBOwnership = true;
        }
      ];
    };
    # Postgress secrets
    sops.secrets."services/postgres/gitea_dbpass" = {
      owner = config.services.gitea.user;
    };

    # Gitea Service
    services.gitea = {
      enable = true;
      settings.server = {
        DOMAIN = "${domain}";
        ROOT_URL = "https://${domain}/";
        HTTP_PORT = 3001;
      };
      appName = "Gitea Tolok"; # Give the site a name

      database = {
        type = "postgres";
      };
      useWizard = false;
    };

  };
}
