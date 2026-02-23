{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.server.prometheus;
in
{
  options.modules.server.prometheus = {
    enable = mkOption {
      description = "Enable Prometheus services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      prometheus = {
        name = "Prometheus";
        info = lib.mkForce "Metrics Database";
        details = lib.mkForce { };
      };
    };

    # Prometheus Services
    services.prometheus = {
      enable = true;
      port = 9001;
      globalConfig.scrape_interval = "10s"; # "1m"
      scrapeConfigs = [
        (mkIf config.services.prometheus.exporters.node.enable {
          job_name = "node";
          static_configs = [
            {
              targets = [ "localhost:${toString config.services.prometheus.exporters.node.port}" ];
            }
          ];
        })
      ];
    };
  };
}
