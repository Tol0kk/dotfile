{
  pkgs,
  lib,
  assets,
  config,
  inputs,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.desktop.wayland.hypr.hyprland;

  isEnableOption =
    enableOption: default: message:
    if (enableOption) then default else "${pkgs.libnotify}/bin/notify-send '${message}'";
in
{
  options.modules.desktop.wayland.hypr.hyprland = {
    enable = mkEnableOpt "Enable Hyprland";
    withEffects = mkEnableOpt "Enable Effects like blur, animation shadow";
    rounding = mkOpt types.int 10 "size fo the rounding";
  };

  config = mkIf cfg.enable {
    services.hyprpaper.enable = false;
    stylix.targets.hyprland.enable = false;

    services.wluma.enable = true;
    # See https://github.com/maximbaz/wluma/blob/main/config.toml for available options.
    services.wluma.settings = { };
    services.wluma.systemd.enable = true; # use systemctl --user stop/start to disable it

    home.file.".config/hypr/hyprland/binding.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/hypr/hyprland/config/binding.conf";

    home.file.".config/hypr/hyprland/exec_once.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/hypr/hyprland/config/exec_once.conf";

    home.file.".config/hypr/hyprland/misc.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/hypr/hyprland/config/misc.conf";

    home.file.".config/hypr/hyprland/monitor.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/hypr/hyprland/config/monitor.conf";

    home.file.".config/hypr/hyprland/plugins.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/hypr/hyprland/config/plugins.conf";

    home.file.".config/hypr/hyprland/window_rules.conf".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/desktop/wayland/hypr/hyprland/config/window_rules.conf";

    home.file.".config/hypr/hyprland/variables.conf".text = ''
      $mainMod = SUPER
      $term = ${config.modules.defaults.terminal}
      $browser = ${config.modules.defaults.browser}
      # $browser = ${inputs.zen-browser.packages."${pkgs.system}".beta}/bin/zen-beta
      # $wallpaper_daemon = ${pkgs.wpaperd}/bin/wpaperd
      $wallpaper_daemon = ${pkgs.swww}/bin/swww img ${assets.backgrounds.background-2}
      $locker = ${pkgs.hyprlock}/bin/hyprlock
      $file_manager = ${config.modules.defaults.file_manager}
      $editor = ${config.modules.defaults.editor}
      $launcher = anyrun
      $bar = ${inputs.hyprpanel.packages."${pkgs.system}".default}/bin/hyprpanel
      $network_applet = nm-applet

      $screenshot_region = ${pkgs.hyprshot}/bin/hyprshot -m region --raw | ${pkgs.satty}/bin/satty -f - -o ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png --action-on-enter save-to-clipboard --early-exit --copy-command wl-copy
      $screenshot_screen = ${pkgs.hyprshot}/bin/hyprshot -m output --raw | ${pkgs.satty}/bin/satty -f - -o ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png --action-on-enter save-to-clipboard --early-exit --copy-command wl-copy
      $screenshot_window = ${pkgs.hyprshot}/bin/hyprshot -m window --raw | ${pkgs.satty}/bin/satty -f - -o ~/Pictures/Screenshots/satty-$(date '+%Y%m%d-%H:%M:%S').png --action-on-enter save-to-clipboard --early-exit --copy-command wl-copy

      $sink_up = ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
      $sink_down = ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
      $sink_toggle_mute = ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      $sink_mute = ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ 1

      $source_up = ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%+
      $source_down = ${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 5%-
      $source_toggle_mute = ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      $source_mute = ${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1

      $media_pause = ${pkgs.playerctl}/bin/playerctl play-pause
      $media_next = ${pkgs.playerctl}/bin/playerctl next
      $media_previous = ${pkgs.playerctl}/bin/playerctl previous

      $brightness_up = ${pkgs.brightnessctl}/bin/brightnessctl s 5%+
      $brightness_down = ${pkgs.brightnessctl}/bin/brightnessctl s 5%-

      $wluma = ${
        isEnableOption config.services.wluma.enable
          "systemctl --user is-active --quiet wluma && systemctl --user stop wluma || systemctl --user start wluma"
          "wluma is not enabled on the system"
      }
    '';

    wayland.windowManager.hyprland = {
      enable = true;
      plugins = [
        pkgs.hyprlandPlugins.hypr-dynamic-cursors
      ];
      extraConfig = ''
        source = ~/.config/hypr/hyprland/variables.conf
        source = ~/.config/hypr/hyprland/*

        ############
        # Aestetics
        ############
        general {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            gaps_in = 5
            gaps_out = 5
            border_size = 2
            col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
            col.inactive_border = rgba(595959aa)
            layout = dwindle
            # Please see https://wiki.hyprland.org/Configuring/Tearing/ before you turn this on
            allow_tearing = false
        }
        decoration {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more

            rounding = ${builtins.toString cfg.rounding}

            blur {
                enabled = ${if (cfg.withEffects) then "true" else "false"}
                size = 10
                passes = 2
            }

            shadow {
                enabled =  ${if (cfg.withEffects) then "true" else "false"}
                range = 4
                render_power = 3
                color = rgba(33ccffee)
            }
        }
        animations {
            enabled = ${if (cfg.withEffects) then "yes" else "no"}
            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
            bezier = myBezier, 0.05, 0.9, 0.1, 1.05
            animation = windows, 1, 7, myBezier
            animation = windowsOut, 1, 7, default, popin 80%
            animation = border, 1, 10, default
            animation = borderangle, 1, 8, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 6, default
        }
      '';
    };
  };
}
