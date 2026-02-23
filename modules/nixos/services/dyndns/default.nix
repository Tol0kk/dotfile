{
  libCustom,
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.services.dyndns;
in
{
  options.modules.services.dyndns = {
    enable = mkEnableOpt "Enable Sync";
    api_env_path = mkOption {
      type = types.nullOr types.path;
      default = null;
    };
    domain = mkOption {
      type = types.str;
      default = config.modules.services.traefik.domain;
    };
  };

  # TODO check
  config = mkIf cfg.enable {
    systemd.services.cloudflare-dyndns = {
      description = "Cloudflare Dynamic DNS";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = ''
          ${pkgs.cloudflare-dyndns}/bin/cloudflare-dyndns \
            --api-token-file ${config.sops.secrets.cloudflare_dyndns.path} \
            ${cfg.domain} *.${cfg.domain}
        '';
      };
    };

    # Run every 5 minutes
    systemd.timers.cloudflare-dyndns = {
      description = "Update Cloudflare DNS";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = "5min";
      };
    };
  };
}
