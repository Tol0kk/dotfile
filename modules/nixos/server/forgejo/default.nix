{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.server.forgejo;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "git.${serverDomain}";
in
{
  options.modules.server.forgejo = {
    enable = mkOption {
      description = "Enable Forgejo services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      forgejo = {
        name = "Forgejo";
        info = lib.mkForce "Git Repository";
        details.listen.text = lib.mkForce domain;
      };
    };

    # Traefik
    modules.server.traefik.enable = true;

    services.traefik = {
      # Forgejo Configuration
      dynamicConfigOptions = {
        http = {
          services.forgejo.loadBalancer.servers = [
            {
              url = "http://localhost:12000";
            }
          ];

          routers.forgejo = {
            entryPoints = [ "websecure" ];
            rule = "Host(`${domain}`)";
            service = "forgejo";
            tls.certResolver = "letsencrypt";
          };
        };
      };
    };

    # Secrets
    sops.secrets.forgejo-mailer-password = {
      owner = config.services.forgejo.user;
      sopsFile = ./secrets.yaml;
    };
    sops.secrets.forgejo-admin-password = {
      owner = config.services.forgejo.user;
      sopsFile = ./secrets.yaml;
    };

    # Forgejo Service
    services.forgejo = {
      enable = true;
      database.type = "postgres";

      settings = {
        server = {
          DOMAIN = "${domain}";
          ROOT_URL = "https://${domain}/";
          HTTP_PORT = 12000;
        };
        service.DISABLE_REGISTRATION = false;
        service.ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
        service.DEFAULT_KEEP_EMAIL_PRIVATE = true;
        service.EMAIL_DOMAIN_BLOCK_DISPOSABLE = true;
        service.DISABLE_USERS_PAGE = true;

        # TODO add Forgejo mailler
        # mailer = {
        #   ENABLED = true;
        #   SMTP_ADDR = "mail.${serverDomain}";
        #   FROM = "noreply@${domain}";
        #   USER = "noreply@${domain}";
        # };
      };

      # TODO add Forgejos mailler
      # mailerPasswordFile = config.sops.secrets."services/forgejo/mailer-password".path;
    };

    # Ensure Admin user
    systemd.services.forgejo.preStart =
      let
        adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        pwd = config.sops.secrets.forgejo-admin-password;
        user = "Tolok_Admin"; # Note, Forgejo doesn't allow creation of an account named "admin"
      in
      ''
        ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        ## uncomment this line to change an admin user which was already created
        # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
      '';
  };
}
