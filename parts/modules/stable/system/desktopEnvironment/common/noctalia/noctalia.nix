{
  flake.homeModules.vicinae =
    {
      pkgs,
      lib,
      config,
      inputs,
      libCustom,
      isPure,
      ...
    }:
    with lib;
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
        source = mkSource ./config "${config.dotfiles}/modules/home/desktop/wayland/shells/noctalia/config";
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
