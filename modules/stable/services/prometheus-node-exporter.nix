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
        };

        # ── Traefik Configuration ────────────────────────────────────────
        # TODO add Traefik configuration

        # ── prometheus-node-exporter Declaration ────────────────────────────────────────
        services.prometheus.exporters.node = {
          enable = true;
          listenAddress = "0.0.0.0";
          port = port;
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
    };
}
