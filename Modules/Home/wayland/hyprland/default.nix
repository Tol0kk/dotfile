{ pkgs, lib, config, color, ... }:

with lib;
let
  cfg = config.modules.wayland.hyprland;
  nvidiacfg = config.modules.nvidia;
  themecfg = config.modules.theme;
  colorScheme = config.modules.theme.colorScheme;
in
{
  options.modules.wayland.hyprland = {
    enable = mkOption {
      description = "Enable hyprland";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      xwayland.enable = true;
      enableNvidiaPatches = true;
    };
    programs.waybar.enable = true;
    wayland.windowManager.hyprland.extraConfig = ''
      exec-once = dbus-update-activation-environment DISPLAY XAUTHORITY WAYLAND_DISPLAY
      exec-once = hyprctl setcursor "${config.gtk.cursorTheme.name}" "${builtins.toString config.gtk.cursorTheme.size }"
      exec-once = waybar
      exec-once = wpaperd
      exec-once = avizo-service
      exec-once = emacs --daemon
      general {
        layout = dwindle
        cursor_inactive_timeout = 30
        no_cursor_warps = false
        border_size = 2
        gaps_in = 3
        gaps_out = 5
        col.active_border = 0xFFC678DD 0xFF9B8C00 0xFF9B8CE4 0xFF9B8C00 0xFFC678DD 45deg
        col.inactive_border = rgba(595959aa)
        resize_on_border = true
        extend_border_grab_area = 15
      }
      input {
        kb_layout = fr,us
        kb_options = grp:alt_shift_toggle, caps:escape
        numlock_by_default = true
        follow_mouse = 1
        touchpad {
          natural_scroll = yes
          disable_while_typing=0
        }
        sensitivity = 0.3 # -1.0 - 1.0, 0 means no modification.
      }
      gestures {
          workspace_swipe=1
          workspace_swipe_fingers=3
          workspace_swipe_distance=200
      }
      decoration {
        rounding = 10
        drop_shadow = true
        shadow_range = 5
        shadow_render_power = 2
        col.shadow = rgba(1a1a1aee)
        blur {
          enabled = true
          size = 10
          passes = 3
          new_optimizations = true
        }
      }
      dwindle {
          pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
          preserve_split = yes # you probably want this
      }
      master {
          new_is_master = true
      }

      env = WLR_DRM_DEVICES,/dev/dri/card1:/dev/dri/card0
      env = QT_QPA_PLATFORMTHEME,qt5ct

      # Monitor
      monitor=,highres,auto,auto

      # Window/Layer Rule.
      layerrule = blur, waybar


      bind = SUPER, T, exec, kitty
      bind = SUPER, return, exec, kitty
      bind = SUPER, Q, killactive,
      bind = SUPER SHIFT, K, exit,
      bind = SUPER, O, exec, thunar
      bind = SUPER, J, togglesplit, # dwindle
      bind = SUPER, F, fullscreen,
      bind = SUPER SHIFT, F, fakefullscreen,
      bind = SUPER, asterisk,togglefloating,
      bind = SUPER, B, exec, brave
      bind = SUPER, E, exec, codium
      bind = SUPER, D, exec, pkill anyrun || anyrun
      bind=ALT,TAB,cyclenext
      bind=ALT,TAB,bringactivetotop
      bind=ALTSHIFT,TAB,cyclenext,prev
      bind=ALTSHIFT,TAB,bringactivetotop

      # Move/resize windows with mainMod + LMB/RMB and dragging
      bindm = SUPER, mouse:272, movewindow
      bindm = SUPER, mouse:273, resizewindow

      # Move focus with mainMod + arrow keys
      bind = SUPER, left, movefocus, l
      bind = SUPER, right, movefocus, r
      bind = SUPER, up, movefocus, u
      bind = SUPER, down, movefocus, d

      # Move window with mainMod + SHIFT + arrow keys
      bind = SUPER SHIFT, left, movefocus, l
      bind = SUPER SHIFT, right, movefocus, r
      bind = SUPER SHIFT, up, movefocus, u
      bind = SUPER SHIFT, down, movefocus, d

      # Switch workspaces with mainMod + [0-9]
      bind = SUPER, ampersand, workspace, 1
      bind = SUPER, eacute, workspace, 2
      bind = SUPER, quotedbl, workspace, 3
      bind = SUPER, apostrophe, workspace, 4
      bind = SUPER, parenleft, workspace, 5
      bind = SUPER, minus, workspace, 6
      bind = SUPER, egrave, workspace, 7
      bind = SUPER, underscore, workspace, 8
      bind = SUPER, ccdella, workspace, 9
      bind = SUPER, agrave, workspace, 10

      # Move active window to a workspace with mainMod + SHIFT + [0-9]
      bind = SUPER SHIFT, ampersand, movetoworkspace, 1
      bind = SUPER SHIFT, eacute, movetoworkspace, 2
      bind = SUPER SHIFT, quotedbl, movetoworkspace, 3
      bind = SUPER SHIFT, apostrophe, movetoworkspace, 4
      bind = SUPER SHIFT, parenleft, movetoworkspace, 5
      bind = SUPER SHIFT, minus, movetoworkspace, 6
      bind = SUPER SHIFT, egrave, movetoworkspace, 7
      bind = SUPER SHIFT, underscore, movetoworkspace, 8
      bind = SUPER SHIFT, ccdella, movetoworkspace, 9
      bind = SUPER SHIFT, agrave, movetoworkspace, 10

      # MEDIA keys
      bindl=,XF86AudioPlay,exec,playerctl play-pause
      bind=,XF86AudioNext,exec,playerctl next
      bind=,XF86AudioPrev,exec,playerctl previous
      # volume button that allows press and hold
      binde=,XF86AudioRaiseVolume,exec,volumectl -u up
      binde=,XF86AudioLowerVolume,exec,volumectl -u down
      binde=,XF86AudioMute,exec,volumectl toggle-mute
      binde=,XF86AudioMicMute,exec,volumectl -m toggle-mute
      binde=,XF86MonBrightnessDown,exec,lightctl down
      binde=,XF86MonBrightnessUp,exec,lightctl up
      # volume button that will activate even while an input inhibitor is active
      bindl=,XF86AudioRaiseVolume,exec,volumectl -u up
      bindl=,XF86AudioLowerVolume,exec,volumectl -u down
      bindl=,XF86AudioMute,exec,volumectl toggle-mute
      bindl=,XF86AudioMicMute,exec,volumectl -m toggle-mute
      bindl=,XF86MonBrightnessDown,exec,lightctl down
      bindl=,XF86MonBrightnessUp,exec,lightctl up


      # SCREENSHOTS
      bind=,print,exec,grimshot save screen ~/Pictures/screenshot/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send "Screenshot saved"
      bind=,f9,exec,grimshot save area ~/Pictures/screenshot/screenshot_$(date +%Y%m%d_%H%M%S).png && notify-send "Section of screenshot saved"
      bind=CTRL,print,exec,grimshot copy screen && notify-send "Screen copied to clipboard"
      bind=SUPER,f9,exec,grimshot copy area && notify-send "Screen part copied to clipboard"

    '';
    xdg.configFile."hypr/hyprland_test.conf".text = ''
      aa = ${
        color.toGradiant [
          colorScheme.border1
          colorScheme.border2
          colorScheme.border1
          colorScheme.border2
          colorScheme.border1
        ] 45
      }
    '';
    home.packages = with pkgs; [
      hyprpicker
      playerctl
      sway-contrib.grimshot
      networkmanagerapplet
      qt5ct # TODO make more test
    ];
  };
}
