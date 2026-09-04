{
  flake.nixosModules.observability =
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
        mkIf
        mkForce
        ;

      pref = config.preferences;
      cfg = config.modules.services.observability;

      # SSO
      kanidmUrl = if pref.sso == null then "https://auth.${pref.topDomain}" else "https://${pref.sso}";

      # Domains
      grafanaLocal = "grafana.local.${pref.topDomain}";
      grafanaPublic = "grafana.${pref.topDomain}";
      promLocal = "prometheus.local.${pref.topDomain}";
      promPublic = "prometheus.${pref.topDomain}";

      # Ports
      grafanaPort = 3235;
      promPort = 9098;
      lokiPort = 3142;
    in
    {
      # ── Modules Settings ────────────────────────────────────────
      options.modules.services.observability = {
        public = mkOption {
          default = pref.public;
          type = types.bool;
          description = "Expose Grafana to the public domain.";
        };

        adminGroups = mkOption {
          type = types.listOf types.str;
          default = [ "grafana_admins@${if pref.sso == null then "auth.${pref.topDomain}" else pref.sso}" ];
          description = ''
            OIDC groups whose members are Grafana admins. Must match exactly what
            Kanidm emits in the groups claim (SPNs).
          '';
        };

        oidc = {
          clientId = mkOption {
            type = types.str;
            default = "grafana";
            description = "OIDC client ID (the Kanidm oauth2 resource-server name).";
          };
        };
      };

      config = {
        # ── Topology / service catalogue ────────────────────────────────────────
        topology.self.services = {
          grafana = {
            name = "Grafana";
            info = lib.mkForce "Observability Dashboard (OIDC via Kanidm)";
            details = {
              Local.text = mkForce "${grafanaLocal} (localhost:${toString grafanaPort})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${grafanaPublic}";
            };
          };
          prometheus = {
            name = "Prometheus";
            info = lib.mkForce "Metrics Server";
            details = {
              Local.text = mkForce "${promLocal} (localhost:${toString promPort})";
            }
            // lib.optionalAttrs cfg.public {
              Public.text = mkForce "${promPublic}";
            };
          };
          loki = {
            name = "Loki";
            info = lib.mkForce "Log Aggregation System";
            details = {
              Local.text = mkForce "(localhost:${toString lokiPort})";
            };
          };
        };

        # ── Glance Services ─────────────────────────────────────────────────────
        modules.services.glance.server_service = [
          {
            title = "Grafana";
            url = if cfg.public then "https://${grafanaPublic}" else "https://${grafanaLocal}";
            check-url = "https://localhost:${toString grafanaPort}/healthz";
            icon = "si:grafana";
          }
          {
            title = "Prometheus";
            url = if cfg.public then "https://${promPublic}" else "https://${promLocal}";
            check-url = "https://localhost:${toString promPort}/-/healthy";
            icon = "si:prometheus";
          }
        ];

        # ── Traefik Configuration ────────────────────────────────────────
        services.traefik.dynamicConfigOptions = {
          http = {
            services = {
              grafana.loadBalancer = {
                servers = [ { url = "http://127.0.0.1:${toString grafanaPort}"; } ];
                healthCheck = {
                  path = "/healthz";
                  interval = "10s";
                  timeout = "3s";
                };
              };
              prometheus.loadBalancer = {
                servers = [ { url = "http://127.0.0.1:${toString promPort}"; } ];
                healthCheck = {
                  path = "/-/healthy";
                  interval = "10s";
                  timeout = "3s";
                };
              };
            };
            routers = {
              # Grafana (Native OIDC handles security)
              grafana = {
                rule =
                  if cfg.public then
                    "Host(`${grafanaLocal}`) || Host(`${grafanaPublic}`)"
                  else
                    "Host(`${grafanaLocal}`)";
                priority = 10;
                entryPoints = [ "websecure" ];
                service = "grafana";
                tls.certResolver = "letsencrypt";
              };

              # Prometheus (No native auth — protected strictly via Kanidm/OAuth middleware)
              prometheus = {
                rule =
                  if cfg.public then "Host(`${promLocal}`) || Host(`${promPublic}`)" else "Host(`${promLocal}`)";
                priority = 100;
                entryPoints = [ "websecure" ];
                service = "prometheus";
                tls.certResolver = "letsencrypt";
                middlewares = [ "kanidm-auth" ];
              };
            };
          };
        };

        # ── Grafana Dashboard ────────────────────────────────────────
        services.grafana = {
          enable = true;
          settings = {
            server = {
              http_port = grafanaPort;
              http_addr = "127.0.0.1";
              domain = if cfg.public then grafanaPublic else grafanaLocal;
              root_url = "https://%(domain)s/";
            };
            security = {
              secret_key = "$__file{${config.sops.secrets."observability/grafana.secret_key".path}}";
            };

            # SSO Configuration
            "auth.generic_oauth" = {
              enabled = true;
              name = "Kanidm";
              allow_sign_up = true;
              client_id = cfg.oidc.clientId;
              client_secret = "$__file{${config.sops.secrets."observability/grafana.oidc_secret".path}}";
              scopes = "openid email profile groups";
              auth_url = "${kanidmUrl}/ui/oauth2";
              token_url = "${kanidmUrl}/oauth2/token";
              api_url = "${kanidmUrl}/oauth2/openid/${cfg.oidc.clientId}/userinfo";
              use_pkce = true;
              # Map Kanidm SPN group to Grafana Admin role. Others get Viewer.
              role_attribute_path = "contains(groups[*], '${builtins.head cfg.adminGroups}') && 'Admin' || 'Viewer'";
            };
          };

          # Automatically wire up Prometheus and Loki
          provision = {
            enable = true;
            datasources.settings.datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:${toString promPort}";
                isDefault = true;
              }
              {
                name = "Loki";
                type = "loki";
                access = "proxy";
                url = "http://127.0.0.1:${toString lokiPort}";
              }
            ];
          };
        };

        # ── Prometheus Metrics ────────────────────────────────────────
        services.prometheus = {
          enable = true;
          port = promPort;
          scrapeConfigs = [
            {
              job_name = "prometheus";
              static_configs = [ { targets = [ "127.0.0.1:${toString promPort}" ]; } ];
            }
          ];
        };

        # ── Loki Log Aggregation ────────────────────────────────────────
        services.loki = {
          enable = true;
          configuration = {
            server.http_listen_port = lokiPort;
            auth_enabled = false;

            common = {
              ring = {
                instance_addr = "127.0.0.1";
                kvstore.store = "inmemory";
              };
              replication_factor = 1;
              path_prefix = "/var/lib/loki";
            };

            limits_config = {
              retention_period = "168h"; # e.g. 7 days
            };

            compactor = {
              working_directory = "/var/lib/loki/compactor";
              retention_enabled = true;
              delete_request_store = "filesystem";
            };

            schema_config = {
              configs = [
                {
                  from = "2024-01-01";
                  store = "tsdb";
                  object_store = "filesystem";
                  schema = "v13";
                  index = {
                    prefix = "index_";
                    period = "24h";
                  };
                }
              ];
            };

            storage_config.filesystem.directory = "/var/lib/loki/chunks";
          };
        };

        # ── Grafana Alloy ────────────────────────────────────────
        services.alloy = {
          enable = true;
        };

        systemd.services.alloy.serviceConfig.SupplementaryGroups = [ "systemd-journal" ];

        environment.etc."alloy/config.alloy".text = ''
          loki.relabel "journal" {
            forward_to = []

            rule {
              source_labels = ["__journal__systemd_unit"]
              target_label  = "unit"
            }
            rule {
              source_labels = ["__journal_priority_keyword"]
              target_label  = "level"
            }
            rule {
              source_labels = ["__journal_syslog_identifier"]
              target_label  = "syslog_identifier"
            }
            rule {
              source_labels = ["__journal__transport"]
              target_label  = "transport"
            }
            rule {
              source_labels = ["__journal__systemd_slice"]
              target_label  = "slice"
            }
            rule {
              source_labels = ["__journal__boot_id"]
              target_label  = "boot_id"
            }
          }

          loki.source.journal "journal" {
            max_age       = "12h"
            relabel_rules = loki.relabel.journal.rules
            labels = {
              job  = "systemd-journal",
              host = "localhost",
            }
            forward_to = [loki.write.local.receiver]
          }

          loki.write "local" {
            endpoint {
              url = "http://127.0.0.1:${toString lokiPort}/loki/api/v1/push"
            }
          }
        '';
        # ── Secrets Declaration ────────────────────────────────────────
        sops.secrets."observability/grafana.secret_key" = {
          owner = "grafana";
          group = "grafana";
        };

        # New secret for OIDC
        sops.secrets."observability/grafana.oidc_secret" = {
          owner = "grafana";
          group = "grafana";
        };
      };
    };
}
