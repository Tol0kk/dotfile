{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.excalidraw;
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "excalidraw.${serverDomain}";
in {
  options.modules.server.excalidraw = {
    enable = mkOption {
      description = "Enable Excalidraw service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      assertions = [
        {
          assertion = !cfg.enable;
          message = "Excalidraw not supported, Please desactivate excalidraw module";
        }
      ];
      # FIXME: Excalidraw docker is only for AMD64

      # # Uptime Kuma Service
      # virtualisation.oci-containers.containers.excalidraw = {
      #   autoStart = true;
      #   image = "docker.io/excalidraw/excalidraw:latest";
      #   ports = [
      #     "127.0.0.1:12456:80"
      #   ];
      # };

      # # Make sure traefik module is options
      # modules.server.traefik.enable = true;

      # services.traefik = {
      #   dynamicConfigOptions = {
      #     http = {
      #       services.excalidraw.loadBalancer.servers = [
      #         {
      #           url = "http://127.0.0.1:12456";
      #         }
      #       ];
      #       routers.excalidraw = {
      #         entryPoints = ["websecure"];
      #         rule = "Host(`${domain}`)";
      #         service = "excalidraw";
      #         tls.certResolver = "letsencrypt";
      #         middlewares = ["oidc-auth"];
      #       };
      #     };
      #   };
      # };
    };
}
