{
  inputs,
  self,
  ...
}:
{
  flake.homeModules.niri =
    {
      pkgs,
      lib,
      config,
      libCustom,
      isPure,
      ...
    }:
    let
      mkSource = relPath: absPath: {
        force = true;
        source = if isPure then relPath else config.lib.file.mkOutOfStoreSymlink absPath;
      };
    in
    {
      imports = [
        self.homeModules.noctalia
        self.homeModules.vicinae
        # self.homeModules.theme
      ];

      config = {

        home.sessionVariables = {
          "QT_QPA_PLATFORMTHEME" = "gtk3";
        };

        home.file.".config/niri" =
          mkSource ./config "${config.dotfiles}/modules/stable/system/desktopEnvironment/niri/config";

        home.packages = [
          pkgs.wdisplays
          pkgs.niri
          pkgs.wl-mirror
          pkgs.wl-clipboard
          pkgs.brightnessctl
          pkgs.gpu-screen-recorder
          pkgs.xwayland-satellite
          pkgs.pwvucontrol
          pkgs.nautilus
          pkgs.libnotify
        ];
      };
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
      imports = [
        self.nixosModules.theme
        self.nixosModules.fonts
        self.nixosModules.noctalia
      ];

      config = {
        # Enable touchpad support (enabled default in most desktopManager).
        services.libinput.enable = true;

        # programs.niri.enable = true;
        programs.niri.useNautilus = false;
        programs.xwayland.enable = false;
        security.polkit.enable = true;
        services.gvfs.enable = true;

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

  flake.wrappersModules.niri =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      binds = ''
        // #'Applications"
        Mod+T hotkey-overlay-title="Terminal" allow-inhibiting=false  { spawn "${lib.getExe pkgs.kitty}"; }
        Mod+Return hotkey-overlay-title="Terminal" { spawn "${lib.getExe pkgs.kitty}"; }
        Mod+B hotkey-overlay-title="Browser" { spawn "zen-beta"; }
        Mod+G hotkey-overlay-title="File Manager" { spawn "${pkgs.xdg-utils}/bin/xdg-open" "."; }
        // Mod+D hotkey-overlay-title="Launcher" allow-inhibiting=false  { spawn "${lib.getExe pkgs.noctalia-shell}" "ipc" "call" "launcher" "toggle"; }
        Mod+D hotkey-overlay-title="Launcher" allow-inhibiting=false  { spawn "${lib.getExe pkgs.vicinae}" "open"; }
        Mod+N hotkey-overlay-title="Binding" { spawn "${lib.getExe pkgs.noctalia-shell}" "ipc" "call" "plugin:keybind-cheatsheet" "toggle";
        Mod+Shift+C hotkey-overlay-title="Lock Screen" allow-inhibiting=false  { spawn "noctalia-shell" "ipc" "call" "sessionMenu" "lockAndSuspend"; }

        // #"Window Management"
        Mod+Q hotkey-overlay-title="Close window" { close-window; }
        Mod+Shift+Q hotkey-overlay-title="Quit Niri" { quit; }
        Mod+V hotkey-overlay-title="Toggle Floating" { toggle-window-floating; }
        Mod+F hotkey-overlay-title="Toggle Maximize" { maximize-column; }
        Mod+Shift+F hotkey-overlay-title="Toggle fullscreen" { fullscreen-window; }
        Mod+Ctrl+F hotkey-overlay-title="Toggle Windowed fullscreen" { toggle-windowed-fullscreen; }
        Mod+O hotkey-overlay-title="Toggle Window Opacity" { toggle-window-rule-opacity; }
        Mod+Escape hotkey-overlay-title="Toggle Keybind inhibit" allow-inhibiting=false  { toggle-keyboard-shortcuts-inhibit; }
        Mod+W hotkey-overlay-title="Toggle Window Column Display" { toggle-column-tabbed-display; }
        Mod+Exclam { set-column-width "+5%"; }
        Mod+Colon { set-column-width "-5%"; }
        Mod+C hotkey-overlay-title="Center Column" { center-column; }
        Mod+Asterisk hotkey-overlay-title="Expend colum width" { expand-column-to-available-width; }
        Mod+R hotkey-overlay-title="Cycle Column Width"  { switch-preset-column-width; }
        // Consume one window from the right to the bottom of the focused column.
        Mod+Comma  { consume-window-into-column; }
        // Expel the bottom window from the focused column to the right.
        Mod+Semicolon { expel-window-from-column; }

        // #"Monitor Management"
        Mod+P repeat=false { spawn-sh "wl-mirror $(niri msg --json focused-output | jq -r .name)"; }
      '';
    in
    {
      config = {
        extraSettings = [
          { include = ./config/misc.kdl; }

          { include = ./config/style.kdl; }
          { include = ./config/inputs.kdl; }
          { screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"; }
        ];

        settings = {
          spawn-sh-at-startup = [
            "${lib.getExe pkgs.noctalia-shell}"
            "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 1"
            "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1"
          ];
        };
      };
    };
  perSystem =
    { pkgs, ... }:
    {
      packages.niri = inputs.wrapper-modules.wrappers.niri.wrap {
        inherit pkgs;
        imports = [ self.wrappersModules.niri ];
      };
    };
}
