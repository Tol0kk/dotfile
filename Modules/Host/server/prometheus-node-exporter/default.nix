{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.prometheus-node-exporter;
  _serverDomain = config.modules.server.cloudflared.domain;
  _tunnelId = config.modules.server.cloudflared.tunnelId;
  _domain = "uptime.${serverDomain}";
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
      services.prometheus.exporters.node = {
        enable = true;
        port = 9000;
        # https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/monitoring/prometheus/exporters.nix
        enabledCollectors = ["systemd"];
        # /nix/store/zgsw0yx18v10xa58psanfabmg95nl2bb-node_exporter-1.8.1/bin/node_exporter  --help
        extraFlags = ["--collector.ethtool" "--collector.softirqs" "--collector.tcpstat" "--collector.wifi"];
      };
    };
}
