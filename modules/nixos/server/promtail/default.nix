{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.server.promtail;
  # serverDomain = config.modules.server.cloudflared.domain;
  # domain = "promtail.${serverDomain}";
in
{
  options.modules.server.promtail = {
    enable = mkOption {
      description = "Enable Promtail services. Equivalent to a Prometheus-node-exporter for logs.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      promtail = {
        name = "Promtail";
        icon = "services.adguardhome"; # TODO create service extractor
        info = lib.mkForce "Log Collector";
      };
    };

    services.promtail = {
      enable = true;
      configuration = {
        server = {
          http_listen_port = 3031;
          grpc_listen_port = 0;
        };
        # Fichier où Promtail stocke les positions des logs déjà lus.
        positions.filename = "/tmp/positions.yaml";
        clients = [
          (mkIf config.modules.server.loki.enable {
            url = "http://127.0.0.1:${toString config.services.loki.configuration.server.http_listen_port}/loki/api/v1/push";
          })
        ];
        scrape_configs = [
          {
            job_name = "systemd-journal";
            journal = {
              path = "/var/log/journal";
              labels = {
                job = "systemd-journal";
              };
            };
            relabel_configs = [
              {
                # Label: `unit` from the systemd unit name (e.g., "sshd.service")
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
              {
                # Label: priority level (e.g., 3 = error, 6 = info)
                source_labels = [ "__journal_priority" ];
                target_label = "priority";
              }
              # {
              #   # Add the hostname as a label
              #   source_labels = ["__journal__hostname"];
              #   target_label = "host";
              # }
            ];
          }
        ];
      };
    };
  };
}
