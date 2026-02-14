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
  cfg = config.modules.system.desktopEnvironment.niri;
in
{
  options.modules.system.desktopEnvironment.niri = {
    enable = mkEnableOpt "Enable Niri Desktop Environment";
    autostart = mkEnableOpt "Enable auto login into niri-session";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      # Enable touchpad support (enabled default in most desktopManager).
      services.libinput.enable = true;

      programs.niri.enable = true;
      programs.niri.useNautilus = false;
      programs.xwayland.enable = false;

      security.polkit.enable = true;

      services.supergfxd.enable = true;

      xdg.portal = {
        enable = true;
        wlr.enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          xdg-desktop-portal-gnome
        ];
        config.common.default = "*";
        configPackages = [ pkgs.niri ];
        config = {
        };
      };
    })
    (mkIf (cfg.enable && cfg.autostart) {

      programs.bash.loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]; then
          exec niri-session
        fi
      '';

      programs.fish.loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]; then
          exec niri-session
        fi
      '';

      programs.zsh.loginShellInit = ''
        if [ "$(tty)" = "/dev/tty1" ]; then
          exec niri-session
        fi
      '';
    })
  ];
}
