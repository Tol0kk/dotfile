{ pkgs, lib, config, pkgs-unstable, ... }:

with lib;
let
  cfg = config.modules.cloudflared;
in
{
  options.modules.cloudflared = {
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
    modules.sops.enable = true;

    sops.secrets."services/cloudflared_HOME_TOKEN" = { owner = config.services.cloudflared.user; };
    services.cloudflared = {
      package = pkgs-unstable.cloudflared;
      enable = true;
      tunnels = {
        "${cfg.tunnelId}" = {
          credentialsFile = "${config.sops.secrets."services/cloudflared_HOME_TOKEN".path}";
          ingress = {
            "www.tolok.org" = {
              service = "http://localhost:8000";
              path = "/index.html";
            };
            "servrock.tolok.org" = {
              service = "ssh://servrock:22";
            };
            "desktop.tolok.org" = {
              service = "ssh://desktop:22";
            };
            "laptop.tolok.org" = {
              service = "ssh://laptop:22";
            };
          };
          default = "http_status:404";
        };
      };
    };

    environment.systemPackages = with pkgs; [
      pkgs-unstable.cloudflared
    ];

    boot.kernel.sysctl."net.core.rmem_max" = 7500000;
    boot.kernel.sysctl."net.core.wmem_max" = 7500000;
  };
}
