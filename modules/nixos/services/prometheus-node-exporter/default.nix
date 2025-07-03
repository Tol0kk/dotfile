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

  # TODO remove old prometheus node exporter
  config = mkIf cfg.enable {
    topology.self.services = {
      prometheus-node-exporter = {
        name = "Node Exporter";
        icon = "services.adguardhome"; # TODO create service extractor
        info = lib.mkForce "Prometeus Exporter";
      };
    };

    services.prometheus.exporters.node = {
      enable = true;
      listenAddress = "0.0.0.0";
      port = 9000;
      # There're already a lot of collectors enabled by default
      # https://github.com/prometheus/node_exporter?tab=readme-ov-file#enabled-by-default
      # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
      enabledCollectors = [
        "systemd"
        "logind"
      ];

      # use either enabledCollectors or disabledCollectors
      # disabledCollectors = [];
    };
  };
}
