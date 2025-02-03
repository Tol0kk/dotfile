{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.forgejo;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "git.${serverDomain}";
in {
  options.modules.server.forgejo = {
    enable = mkOption {
      description = "Enable Forgejo services";
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
          service = "http://localhost:3000";
        };
      };

      # Secrets
      sops.secrets."services/forgejo/mailer-password" = {
        owner = config.services.forgejo.user;
      };

      # Forgejo Service
      services.forgejo = {
        enable = true;
        database.type = "postgres";

        settings = {
          server = {
            DOMAIN = "${domain}";
            ROOT_URL = "https://${domain}/";
            HTTP_PORT = 3000;
          };
          service.DISABLE_REGISTRATION = true;

          # TODO Add support for actions, based on act: https://github.com/nektos/act
          # actions = {
          #   ENABLED = true;
          #   DEFAULT_ACTIONS_URL = "github";
          # };

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
      systemd.services.forgejo.preStart = let
        adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        pwd = config.sops.secrets.forgejo-admin-password;
        user = "Tolok_Admin"; # Note, Forgejo doesn't allow creation of an account named "admin"
      in ''
        ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
        ## uncomment this line to change an admin user which was already created
        # ${adminCmd} change-password --username ${user} --password "$(tr -d '\n' < ${pwd.path})" || true
      '';

      # TODO Add runner
      # services.gitea-actions-runner = {
      #   package = pkgs.forgejo-actions-runner;
      #   instances.default = {
      #     enable = true;
      #     name = "monolith";
      #     url = "https://git.example.com";
      #     # Obtaining the path to the runner token file may differ
      #     # tokenFile should be in format TOKEN=<secret>, since it's EnvironmentFile for systemd
      #     tokenFile = config.age.secrets.forgejo-runner-token.path;
      #     labels = [
      #       "ubuntu-latest:docker://node:16-bullseye"
      #       "ubuntu-22.04:docker://node:16-bullseye"
      #       "ubuntu-20.04:docker://node:16-bullseye"
      #       "ubuntu-18.04:docker://node:16-buster"
      #       ## optionally provide native execution on the host:
      #       # "native:host"
      #     ];
      #   };
      # };
    };
}
