{ self, ... }:
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
      imports = [
        self.homeModules.noctalia
        self.homeModules.vicinae
        self.homeModules.theme
        self.homeModules.fonts
      ];

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
        pkgs.pwvucontrol
      ];
    };

  flake.nixosModules.niri =
    {
      lib,
      config,
      pkgs,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    {
      config = {
        # Enable touchpad support (enabled default in most desktopManager).
        services.libinput.enable = true;

        programs.niri.enable = true;
        programs.niri.useNautilus = false;
        programs.xwayland.enable = false;
        security.polkit.enable = true;

        xdg.portal = {
          enable = true;
          wlr.enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-gnome
          ];
          config.common.default = "*";
          configPackages = [ pkgs.niri ];
        };

        # For auto-login
        services.greetd.settings.default_session.command =
          "${pkgs.greetd}/bin/agreety --cmd ${pkgs.bash}/bin/bash";
        services.greetd.settings.initial_session.command = "niri-session";
      };
    };
}
