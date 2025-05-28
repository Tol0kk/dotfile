{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.fail2ban;
in {
  options.modules.server.fail2ban = {
    enable = mkOption {
      description = "Enable fail2ban services";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      services.fail2ban = {
        enable = true;
        # Ban IP after 5 failures
        maxretry = 5;
        ignoreIP = [
          # Whitelist some subnets
          "10.0.0.0/8"
          "172.16.0.0/12"
          "192.168.0.0/16"
          "tolok.org" # resolve the IP via DNS
        ];
        bantime = "30m"; # Ban IPs for one day on the first ban
        bantime-increment = {
          enable = true; # Enable increment of bantime after each violation
          # formula = "ban.Time * math.exp(float(ban.Count+1)*banFactor)/math.exp(1*banFactor)";
          multipliers = "1 2 4 8 16 32 64 128 256 512";
          maxtime = "168h"; # Do not ban for more than 1 week
          overalljails = true; # Calculate the bantime based on all the violations
        };
      };
    };
}
