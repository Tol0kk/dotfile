{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.grafana;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "grafana.${serverDomain}";
in {
  options.modules.server.grafana = {
    enable = mkOption {
      description = "Enable Grafana services";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      topology.self.services = {
        grafana = {
          name = "Grafana";
          info = lib.mkForce "Metrics & Logs Dashboard";
          details.listen.text = lib.mkForce domain;
        };
      };

      # Traefik
      modules.server.traefik.enable = true;

      services.traefik = {
        # Grafana Configuration
        dynamicConfigOptions = {
          http = {
            services.grafana.loadBalancer.servers = [
              {
                url = "http://127.0.0.1:47726";
              }
            ];

            routers.grafana = {
              entryPoints = ["websecure"];
              rule = "Host(`${domain}`)";
              service = "grafana";
              tls.certResolver = "letsencrypt";
              middlewares = ["oidc-auth"];
            };
            routers.grafanaHealth = {
              entryPoints = ["websecure"];
              rule = "Host(`${domain}`) && Path(`/api/health`)";
              service = "grafana";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };

      # Secrets
      sops.secrets.admin_password = {
        owner = config.systemd.services.grafana.serviceConfig.User;
        sopsFile = ./secrets.yaml;
      };

      # Grafana Services
      services.grafana = {
        enable = true;
        settings = {
          server = {
            http_addr = "127.0.0.1";
            http_port = 47726;
            enforce_domain = true;
            enable_gzip = true;
            domain = domain;
          };

          # Prevents Grafana from phoning home
          analytics.reporting_enabled = false;
          # Disable creation of a Grafana Admin user on first start of Grafana
          security.disable_initial_admin_creation = false;
          security.admin_user = "Odin";
          security.admin_password = "$__file{${config.sops.secrets.admin_password.path}}";
        };
        provision = {
          enable = true;
          datasources.settings.datasources = [
            (mkIf config.modules.server.prometheus.enable {
              name = "Prometheus";
              type = "prometheus";
              access = "proxy";
              url = "http://${config.services.prometheus.listenAddress}:${toString config.services.prometheus.port}";
            })
            (mkIf config.modules.server.loki.enable {
              name = "Loki";
              type = "loki";
              access = "proxy";
              url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}";
            })
          ];
        };
      };
    };
}
