{
  flake.nixosModules.tino =
    {
      lib,
      config,
      ...
    }:
    let
      inherit (lib)
        types
        mkOption
        mkForce
        ;
      pref = config.preferences;
      cfg = config.modules.services.tino;

      kanidmUrl = if pref.sso == null then "https://auth.${pref.topDomain}" else "https://${pref.sso}";

      local = "typst.local.${pref.topDomain}";
      public = "typst.${pref.topDomain}";

      hostPort = 5048;
      containerPort = 5000;
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.tino = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
        };

        image = mkOption {
          type = types.str;
          default = "ghcr.io/confirm/tino:latest";
          description = "TINO container image (pin a version tag in production).";
        };

        dataDir = mkOption {
          type = types.str;
          default = "/var/lib/tino";
          description = "Host path bind-mounted at /data (git buckets, fonts, api keys).";
        };

        adminGroups = mkOption {
          type = types.listOf types.str;
          default = [ "admins" ];
          description = ''
            OIDC groups whose members are TINO admins. Must match exactly what
            Kanidm emits in the groups claim — Kanidm sends group SPNs, e.g.
            "tino_admins@${pref.topDomain}", not the short name.
          '';
        };

        defaultRole = mkOption {
          type = types.enum [
            "none"
            "viewer"
            "editor"
            "committer"
          ];
          default = "viewer";
          description = "Role for authenticated users on buckets without an ACL.";
        };

        oidc = {
          discoveryUrl = mkOption {
            type = types.str;
            example = "https://idm.${pref.topDomain}/oauth2/openid/tino/.well-known/openid-configuration";
            description = "Kanidm OIDC discovery URL for the TINO client.";
          };
          clientId = mkOption {
            type = types.str;
            default = "tino";
            description = "OIDC client ID (the Kanidm oauth2 resource-server name).";
          };
          groupsClaim = mkOption {
            type = types.str;
            default = "groups";
            description = "Token claim carrying group memberships.";
          };
        };

      };

      config = {
        # ── Persistent data dir owned by the in-container uid/gid (1234) ─────────
        systemd.tmpfiles.rules = [
          "d ${cfg.dataDir} 0750 1234 1234 - -"
        ];

        # ── The container ───────────────────────────────────────────────────────
        virtualisation.oci-containers.containers.tino = {
          inherit (cfg) image;
          ports = [ "127.0.0.1:${toString hostPort}:${toString containerPort}" ];
          volumes = [ "${cfg.dataDir}:/data" ];
          environmentFiles = [ config.sops.secrets."tino/env.secrets".path ];
          environment = {
            TINO_BASE_URL = "https://" + (if cfg.public then public else local);
            TINO_OIDC_DISCOVERY_URL = "${kanidmUrl}/oauth2/openid/tino/.well-known/openid-configuration";
            TINO_OIDC_CLIENT_ID = "tino";
            TINO_OIDC_GROUPS_CLAIM = cfg.oidc.groupsClaim;
            TINO_ADMIN_GROUPS = "tino_admins@auth.othrys.tolok.org";
            TINO_DEFAULT_ROLE = cfg.defaultRole;
          };
        };

        sops.secrets."tino/env.secrets" = { };

        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          tino = {
            name = "TINO";
            info = lib.mkForce "Self-hosted Typst editor (OIDC via Kanidm)";
            details = {
              "Local".text = mkForce "${local} (localhost:${toString hostPort})";
            }
            // lib.optionalAttrs cfg.public {
              "Public".text = mkForce "${public}";
            };
          };
        };

        # ── Glance Services ─────────────────────────────────────────────────────
        modules.services.glance.server_service = [
          {
            title = "TINO";
            url = if cfg.public then "https://${public}" else "https://${local}";
            check-url = "https://${local}/health";
            icon = "si:typst";
          }
        ];

        # ── Traefik Configuration ───────────────────────────────────────────────
        # No kanidm-auth middleware here: TINO authenticates against Kanidm itself.
        services.traefik.dynamicConfigOptions = {
          http = {
            services.tino.loadBalancer = {
              servers = [
                { url = "http://127.0.0.1:${toString hostPort}"; }
              ];
              healthCheck = {
                path = "/health";
                interval = "10s";
                timeout = "3s";
              };
            };
            routers.tino = {
              entryPoints = [ "websecure" ];
              rule = if cfg.public then "Host(`${local}`) || Host(`${public}`)" else "Host(`${local}`)";
              service = "tino";
              tls.certResolver = "letsencrypt";
            };
          };
        };
      };
    };
}
