{
  flake.nixosModules.adguard =
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
      cfg = config.modules.services.adguard;

      local = "adguard.local.${pref.topDomain}";
      public = "adguard.${pref.topDomain}";
      port = 3047;
    in
    {
      options.modules.services.adguard = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };
      };

      config = {
        services.resolved.settings.Resolve.DNSStubListener = "no";
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          adguard = {
            name = "AdGuard";
            info = lib.mkForce "Self hosted DNS";
            details = {
              "Local DashBoard".text = mkForce "${local} (localhost:${toString port})";
              "Local DNS".text = mkForce "${local}:53 localhost:53)";
            }
            // lib.optionalAttrs cfg.public {
              "Public DashBoard".text = mkForce "${public}";
            };
          };
        };

        # Glance Services
        modules.services.glance.server_service = [
          {
            title = "AdGuard Home DashBoard";
            url = if cfg.public then "https://${public}" else "https://${local}";
            check-url = "https://${local}/";
            icon = "si:adguard";
          }
        ];

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions = {
          http = {
            services.adguard.loadBalancer = {
              servers = [
                { url = "http://127.0.0.1:${toString port}"; }
              ];
              healthCheck = {
                path = "/";
                interval = "10s";
                timeout = "3s";
              };
            };
            routers.adguard = {
              entryPoints = [ "websecure" ];
              rule = if cfg.public then "Host(`${local}`) || Host(`${public}`)" else "Host(`${local}`)";
              service = "adguard";
              tls.certResolver = "letsencrypt";
              middlewares = [ "kanidm-auth" ];
            };
          };
        };

        # ── AdGuard Home Configuration ────────────────────────────────────────
        services.adguardhome = {
          enable = true;
          host = "127.0.0.1"; # UI bound to localhost; Traefik is the only web path
          inherit port;
          mutableSettings = false; # fully declarative
          settings = {
            dns.bootstrap_dns = [
              "1.1.1.1" # CloudFlare
              "9.9.9.9" # Quad9
            ];
            dns.upstream_dns = [ "https://dns.quad9.net/dns-query" ];
          };
        };

        networking.firewall.allowedUDPPorts = lib.optionals pref.openFirewall [ 53 ];
        networking.firewall.allowedTCPPorts = lib.optionals pref.openFirewall [ 53 ];
      };
    };
}
