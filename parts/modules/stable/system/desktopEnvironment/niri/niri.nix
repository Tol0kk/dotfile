{
  flake.homeModules.vicinae =
    {
      pkgs,
      lib,
      config,
      libCustom,
      isPure,
      ...
    }:
    with lib;
    with libCustom;
    {
      home.sessionVariables = {
        "QT_QPA_PLATFORMTHEME" = "gtk3";
      };

      home.file.".config/niri".source =
        mkSource isPure ./config
          "${config.dotfiles}/modules/home/desktop/wayland/niri/config";

      home.packages = [
        pkgs.niri
        pkgs.wl-mirror
        pkgs.wl-clipboard
        pkgs.brightnessctl
        pkgs.gpu-screen-recorder
        pkgs.xwayland-satellite
      ];
    };
}
