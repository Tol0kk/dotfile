{
  pkgs,
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib;
let
  cfg = config.modules.server.cloudflared;
in
{
  options.modules.server.cloudflared = {
    enable = mkOption {
      description = "Enable Cloudflared Tunnel services";
      type = types.bool;
      default = false;
    };
    domain = mkOption {
      description = "Domain to link the provided tunnel.";
      type = types.str;
    };
    tunnelId = mkOption {
      description = "Cloudflare tunnel Id";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    # Need sops for secrets
    modules.system.sops.enable = true;

    services.cloudflared = {
      package = pkgs-unstable.cloudflared;
      enable = true;
    };

    environment.systemPackages = with pkgs; [
      pkgs-unstable.cloudflared
    ];

    boot.kernel.sysctl."net.core.rmem_max" = 7500000;
    boot.kernel.sysctl."net.core.wmem_max" = 7500000;
  };
}
