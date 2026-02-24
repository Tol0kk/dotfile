{
  flake.homeModules.syncthings =
    {
      lib,
      config,
      pkgs,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    let
      cfg = config.modules.services.syncthing;
    in
    {
      options.modules.services.syncthing = {
        key = mkOpt types.path null "path to a key.pem";
        cert = mkOpt types.path null "path to a cert.pem";
      };

      config = {
        services.syncthing = {
          enable = true;
          tray = {
            enable = true;
            package = pkgs.syncthingtray;
            command = "syncthingtray --wait";
          };
          key = cfg.key;
          cert = cfg.cert;
          extraOptions = [ ];
        };

        # Workaround for Failed to restart syncthingtray.service: Unit tray.target not found.
        # - https://github.com/nix-community/home-manager/issues/2064
        systemd.user.targets.tray = {
          Unit = {
            Description = "Home Manager System Tray";
            Requires = [ "graphical-session-pre.target" ];
          };
        };
      };
    };
}
