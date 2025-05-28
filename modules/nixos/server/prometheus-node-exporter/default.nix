{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.prometheus-node-exporter;
in {
  options.modules.server.prometheus-node-exporter = {
    enable = mkOption {
      description = "Enable prometheus-node-exporter service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      topology.self.services = {
        prometheus-node-exporter = {
          name = "Node Exporter";
          icon = "services.adguardhome"; # TODO create service extractor
          info = lib.mkForce "Prometeus Exporter";
        };
      };

      services.prometheus.exporters.node = {
        enable = true;
        port = 9000;
        # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
        enabledCollectors = ["systemd"];
        # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
        extraFlags = ["--collector.ethtool" "--collector.softirqs"];
      };
    };
}
