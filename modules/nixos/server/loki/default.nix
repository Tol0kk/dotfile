{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.loki;
in {
  options.modules.server.loki = {
    enable = mkOption {
      description = "Enable Loki services. Equivalent to a Prometheus database for logs.";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      topology.self.services = {
        loki = {
          name = "Loki";
          info = lib.mkForce "Logs Collector";
        };
      };

      services.loki = {
        enable = true;
        configuration = {
          server.http_listen_port = 3030;
          auth_enabled = false;

          ingester = {
            lifecycler = {
              address = "127.0.0.1";
              ring = {
                kvstore = {
                  store = "inmemory"; # No external KV store (for single-node setup)
                };
                replication_factor = 1; # Only one replica needed (again, single-node)
              };
            };
            chunk_idle_period = "1h"; # Flush chunk if no new logs in 30 min
            chunk_target_size = 999999;
            chunk_retain_period = "30s"; # Keep chunk in memory briefly after flush
            # max_transfer_retries = 0; # No retrying needed for transfers in single-node
          };

          schema_config = {
            configs = [
              {
                from = "2025-04-06";
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

          storage_config = {
            tsdb_shipper = {
              active_index_directory = "/var/lib/loki/index";
              cache_location = "/var/lib/loki/index_cache";
              cache_ttl = "168h"; # Can be increased for faster performance over longer query periods, uses more disk space
            };

            filesystem = {
              directory = "/var/lib/loki/chunks";
            };
          };

          limits_config = {
            retention_period = "720h"; # Auto-delete logs after 30 days
            reject_old_samples = true; # Don't accept logs older than max age
            reject_old_samples_max_age = "168h"; # 7 days max age for ingested logs
          };

          table_manager = {
            # Handles retention & deletion of old index/chunk data
            retention_deletes_enabled = true; # Enable deletion of old logs
            retention_period = "0s"; # Keep logs for 30 days
          };

          compactor = {
            working_directory = "/var/lib/loki";
            compactor_ring = {
              kvstore = {
                store = "inmemory";
              };
            };
          };
        };
      };
    };
}
