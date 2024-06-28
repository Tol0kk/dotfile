{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.gitea;
in
{
  options.modules.gitea = {
    enable = mkOption {
      description = "Enable Gitea services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true; # Enable Nginx
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;
      virtualHosts."source.MyDomain.tld" = {
        # Gitea hostname
        enableACME = false; # Use ACME certs
        forceSSL = false; # Force SSL
        locations."/".proxyPass = "http://localhost:3001/"; # Proxy Gitea
      };
    };
    services.postgresql = {
      enable = true; # Ensure postgresql is enabled
      authentication = ''
        local gitea all ident map=gitea-users
      '';
      identMap = # Map the gitea user to postgresql
        ''
          gitea-users gitea gitea
        '';
    };

    sops.secrets."services/postgres/gitea_dbpass" = {
      owner = config.services.gitea.user;
    };

    services.gitea = {
      enable = true;
      appName = "My awesome Gitea server"; # Give the site a name
      database = {
        type = "postgres";
        passwordFile = config.sops.secrets."services/postgres/gitea_dbpass".path;
      };
      useWizard = true;
      settings.server = {
        DOMAIN = "git.my-domain.tld";
        ROOT_URL = "https://git.my-domain.tld/";
        HTTP_PORT = 3001;
      };
    };


  };
}
