{
  flake.nixosModules.prometheus-node-exporter =
    {
      lib,
      config,
      libCustom,
      ...
    }:
    let
      inherit (lib)
        types
        mkOption
        mkForce
        ;
      pref = config.preferences;
      cfg = config.modules.services.prometheus-node-exporter;
      local = "prometheus-node-exporter.local.${pref.topDomain}";
      public = "prometheus-node-exporter.${pref.topDomain}";
      port = 9000;
      processPort = 9256;
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.prometheus-node-exporter = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };
      };
      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          prometheus-node-exporter = {
            icon = "services.prometheus";
            name = "Node Exporter";
            info = lib.mkForce "Prometeus Exporter";
            details = {
              Local.text = mkForce "${local} (localhost:${toString port})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public}";
            };
          };
          prometheus-process-exporter = {
            icon = "services.prometheus";
            name = "Process Exporter";
            info = lib.mkForce "Prometheus Per-Process Exporter";
            details = {
              Local.text = mkForce "localhost:${toString processPort}";
            };
          };
        };
        # ── prometheus-node-exporter Declaration ────────────────────────────────────────
        services.prometheus.exporters.node = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = port;
          enabledCollectors = [
            "systemd"
            "logind"
          ];
        };
        # ── prometheus-process-exporter Declaration ────────────────────────────────────────
        services.prometheus.exporters.process = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = processPort;
          settings.process_names = [
            # Group every process by its executable name (comm)
            {
              name = "{{.Comm}}";
              cmdline = [ ".+" ];
            }
          ];
        };
        services.prometheus.globalConfig.scrape_interval = "15s";
        services.prometheus.scrapeConfigs = [
          {
            job_name = "Othrys Node";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString port}" ];
                labels.instance = config.networking.hostName;
              }
            ];
          }
          {
            job_name = "Othrys Process";
            static_configs = [
              {
                targets = [ "127.0.0.1:${toString processPort}" ];
                labels.instance = config.networking.hostName;
              }
            ];
          }
        ];
      };
    };
}
