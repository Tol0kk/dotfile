{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.services.prometheus-node-exporter;
in {
  options.modules.services.prometheus-node-exporter = {
    enable = mkEnableOpt "Enable Prometheus node exports on the system";
  };

  config = mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 9100;
      # There're already a lot of collectors enabled by default
      # https://github.com/prometheus/node_exporter?tab=readme-ov-file#enabled-by-default
      enabledCollectors = [
        "systemd"
        "logind"
      ];

      # use either enabledCollectors or disabledCollectors
      # disabledCollectors = [];
    };
  };
}
