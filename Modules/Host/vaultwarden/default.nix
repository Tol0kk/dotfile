{ pkgs, lib, config, pkgs-unstable, ... }:

with lib;
let
  cfg = config.modules.vaultwarden;
  serverDomain = config.modules.cloudflared.domain;
  tunnelId = config.modules.cloudflared.tunnelId;
  domain = "vaultwarden.${serverDomain}";
in
{
  options.modules.vaultwarden = {
    enable = mkOption {
      description = "Enable Vaultwarden services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {

    # Cloudflare Tunnel (Reverse Proxy)
    services.cloudflared = {
      tunnels."${tunnelId}".ingress."${domain}" = {
        service = "http://localhost:8222";
      };
    };

    # Vaultwarden Service
    services.vaultwarden = {
      enable = true;
      webVaultPackage = pkgs-unstable.pkgsCross.aarch64-multiplatform.vaultwarden.webvault;
      package = pkgs-unstable.pkgsCross.aarch64-multiplatform.vaultwarden;
      config = {
        DOMAIN = "https://${domain}";
        ROCKET_PORT = 8222;
        WEB_VAULT_ENABLED = true;
      };
    };

  };
}
