{
  flake.nixosModules.vaultwarden =
    {
      lib,
      config,
      libCustom,
      pkgs-unstable,
      ...
    }:
    let
      inherit (lib)
        types
        mkOption
        mkForce
        ;
      pref = config.preferences;
      cfg = config.modules.services.glance;

      local = "vaultwaren.local.${pref.topDomain}";
      public = "vaultwaren.${pref.topDomain}";
      port = 8222;
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.glance = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          glance = {
            name = "vaultwarden";
            info = lib.mkForce "Self hosted password manager";
            details = {
              Local.text = mkForce "${local} (localhost:${toString port})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${public}";
            };
          };
        };

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions = {
          http = {
            services.vaultwarden.loadBalancer.servers = [
              { url = "http://127.0.0.1:${toString port}"; }
            ];
            routers.vaultwarden = {
              rule = if cfg.public then "Host(`${local}`) || Host(`${public}`)" else "Host(`${local}`)";
              priority = 10;
              entryPoints = [ "websecure" ];
              service = "vaultwarden";
              tls.certResolver = "letsencrypt";
            };
          };
        };

        # ── Vaultwaredn config ────────────────────────────────────────
        services.vaultwarden = {
          enable = true;
          webVaultPackage = pkgs-unstable.pkgsCross.aarch64-multiplatform.vaultwarden.webvault;
          package = pkgs-unstable.pkgsCross.aarch64-multiplatform.vaultwarden;
          config = {
            DOMAIN = if cfg.public then "https://${public}" else "https://${local}";
            ROCKET_PORT = port;
            WEB_VAULT_ENABLED = true;
          };
        };
      };
    };
}
