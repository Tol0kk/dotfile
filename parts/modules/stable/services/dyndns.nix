{ self, ... }:
{
  flake.nixosModules.dyndns =
    {
      libCustom,
      lib,
      config,
      pkgs,
      ...
    }:
    let
      pref = config.preferences;
    in
    {
      config = {
        topology.self.services = {
          dyndns = {
            icon = "${self}/assets/icons/cloudflare.svg";
            name = "DynDNS";
            info = lib.mkForce "Dynamic DNS for ${pref.topDomain}";
          };
        };

        # ── DynDNS Configuration ────────────────────────────────────────
        systemd.services.cloudflare-dyndns = {
          description = "Cloudflare Dynamic DNS";
          after = [ "network-online.target" ];
          wants = [ "network-online.target" ];
          wantedBy = [ "multi-user.target" ];

          serviceConfig = {
            Type = "oneshot";
            ExecStart = ''
              ${pkgs.cloudflare-dyndns}/bin/cloudflare-dyndns \
                --api-token-file ${config.sops.secrets."cloudflare/dyndns".path} \
                ${pref.topDomain} *.${pref.topDomain}
            '';
          };
        };

        # ── Misc ────────────────────────────────────────

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
    };
}
