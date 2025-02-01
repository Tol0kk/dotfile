{
  pkgs,
  lib,
  config,
  pkgs-unstable,
  ...
}:
with lib; let
  cfg = config.modules.ttrss;
  serverDomain = config.modules.server.cloudflared.domain;
  tunnelId = config.modules.server.cloudflared.tunnelId;
  domain = "ttrss.${serverDomain}";
in {
  options.modules.ttrss = {
    enable = mkOption {
      description = "Enable TT-RSS services";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # # Cloudflare Tunnel (Reverse Proxy)
    # services.cloudflared = {
    #   tunnels."${tunnelId}".ingress."${domain}" = {
    #     service = "http://localhost:8222";
    #   };
    # };

    # TT-RSS Service
    services.tt-rss = {
      enable = true;
      selfUrlPath = "http://localhost";
    };
  };
}
