{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.services.kodi;
  traefikcfg = config.modules.services.traefik;
in {
  options.modules.services.kodi = {
    enable = mkEnableOpt "Enable kodi homepage";
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      kodi = {
        name = "kodi";
        info = lib.mkForce "Self hosted homepage/dashboard";
      };
    };

    services.traefik = {
      # kodi Configuration
      dynamicConfigOptions = {
        http = {
          services.kodi.loadBalancer.servers = [
            {
              url = "http://127.0.0.1:8080";
            }
          ];

          routers.kodi = {
            rule = "Host(`kodi.${traefikcfg.domain}`)";
            entryPoints = ["websecure"];
            service = "kodi";
            tls = traefikcfg.tlsConfig; # Uses Traefik's default self-signed cert
          };
        };
      };
    };

    environment.systemPackages = [
      (pkgs.kodi.withPackages (kodiPkgs: with kodiPkgs; [jellyfin]))
    ];
  };
}
