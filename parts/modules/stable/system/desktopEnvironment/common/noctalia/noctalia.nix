{ inputs, ... }:
{
  flake.homeModules.noctalia =
    {
      pkgs,
      lib,
      config,
      libCustom,
      isPure,
      ...
    }:
    let
      inherit (libCustom) mkSource;
    in
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      stylix.targets.noctalia-shell.enable = false;
      programs.noctalia-shell = {
        enable = true;
      };

      home.file.".config/noctalia" = {
        source =
          mkSource isPure ./config
            "${config.dotfiles}/modules/home/desktop/wayland/shells/noctalia/config";
        recursive = true;
      };
      home.sessionVariables = {
        # QT_QPA_PLATFORMTHEME = "gtk3";
      };

      home.packages = [
        pkgs.quickshell
        pkgs.gpu-screen-recorder
      ];
    };
}
