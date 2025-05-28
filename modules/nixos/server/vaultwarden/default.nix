{
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.server.vaultwarden;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "vaultwarden.${serverDomain}";
in {
  options.modules.server.vaultwarden = {
    enable = mkOption {
      description = "Enable Vaultwarden services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      vaultwarden = {
        name = "Vaultwarden";
        info = lib.mkForce "Password Manager";
        details.listen.text = lib.mkForce domain;
      };
    };

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
