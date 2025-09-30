{
  pkgs,
  lib,
  config,
  inputs,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.desktop.wayland.hypr.hyprland;
in {
  options.modules.desktop.wayland.hypr.hyprland = {
    enable = mkEnableOpt "Enable Hyprland";
    withEffects = mkEnableOpt "Enable Effects like blur, animation shadow";
    rounding = mkOpt types.int 10 "size fo the rounding";
    apps = {
      terminal = mkOpt types.str null "Terminal application used used";
    };
  };

  config = mkIf cfg.enable {
    services.hyprpaper.enable = false;
    stylix.targets.hyprland.enable = false;
    wayland.windowManager.hyprland = {
      enable = true;
      extraConfig = ''
        monitor=,preferred,auto,auto
        monitor=Unknown-1,disabled
        monitor=DP-5,preferred,auto,auto
        monitorv2 {
                output = HDMI-A-1
                mode = preferred
                position = auto-center-left
                scale = 2
                transform = 2
        }

        ############
        # Variables
        ############

        $mainMod = SUPER
        $term = ${cfg.apps.terminal}
        $browser = ${inputs.zen-browser.packages."${pkgs.system}".beta}/bin/zen-beta
        $wallpaper_daemon = ${pkgs.wpaperd}/bin/wpaperd
        $locker = ${pkgs.hyprlock}/bin/hyprlock
        $file_manager = ${pkgs.nautilus}/bin/nautilus
        $launcher = anyrun
        $bar = ${pkgs.waybar}/bin/waybar

        ############
        # Execute at Launch
        ############
        exec-once = volumectl mute 	                      # Mute speaker
        exec-once = volumectl -m mute	                      # Mute microphone
        # exec-once = $wallpaper_daemon 		              # Activate wpaperd
        # exec-once = $bar		                      # Activate wpaperd
        exec-once = = ${inputs.hyprpanel.packages."${pkgs.system}".default}/bin/hyprpanel

        ############
        # General Inputs Settings
        ############
        input {
            kb_layout = fr, us
            kb_variant =
            kb_model =
            kb_options = grp:alt_shift_toggle
            kb_rules =

            follow_mouse = 1

            touchpad {
                disable_while_typing = false
                natural_scroll = yes
            }

            sensitivity = 0 # -1.0 - 1.0, 0 means no modification.
        }
        gestures {
            # See https://wiki.hyprland.org/Configuring/Variables/ for more
            workspace_swipe = on
        }

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
                enabled = ${
          if (cfg.withEffects)
          then "true"
          else "false"
        }
                size = 10
                passes = 2
            }

            shadow {
                enabled =  ${
          if (cfg.withEffects)
          then "true"
          else "false"
        }
                range = 4
                render_power = 3
                color = rgba(33ccffee)
            }
        }
        animations {
            enabled = ${
          if (cfg.withEffects)
          then "yes"
          else "no"
        }
            # Some default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
            bezier = myBezier, 0.05, 0.9, 0.1, 1.05
            animation = windows, 1, 7, myBezier
            animation = windowsOut, 1, 7, default, popin 80%
            animation = border, 1, 10, default
            animation = borderangle, 1, 8, default
            animation = fade, 1, 7, default
            animation = workspaces, 1, 6, default
        }
        dwindle {
            # See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
            pseudotile = yes # master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
            preserve_split = yes # you probably want this
        }
        misc {
            # See https://wiki.hyprland.org/Confimkguring/Variables/ for more
            force_default_wallpaper = 0 # Set to 0 to disable the anime mascot wallpapers
            enable_anr_dialog=false
            disable_hyprland_logo=true
            disable_splash_rendering=true
        }

        ############
        # Window Rules
        ############

        # Example windowrule v1
        # windowrule = float, ^(kitty)$
        # Example windowrule v2
        windowrulev2 = opacity 0.85,class:^(emacs)$
        windowrulev2 = opaque,class:^(emacs)$
        # See https://wiki.hyprland.org/Configuring/Window-Rules/ for more

        # See https://wiki.hyprland.org/Configuring/Keywords/ for more


        ############
        # Bindings
        ############
        # Example binds, see https://wiki.hyprland.org/Configuring/Binds/ for more

        # Apps Shortcuts
        bind = $mainMod, T, exec, $term
        bind = $mainMod, Return, exec, $term
        bind = $mainMod, B, exec, $browser
        bind = $mainMod, O, exec, $file_manager
        bind = $mainMod, D, exec, $launcher

        # WM actions
        bind = $mainMod, C, exec, $locker
        bind = $mainMod, Q, killactive,
        bind = $mainMod SHIFT, Q, exit,
        bind = $mainMod, V, togglefloating,
        bind = $mainMod, F, fullscreen,
        bind = $mainMod, P, togglesplit, # dwindle

        # Move focus with mainMod + arrow keys
        bind = $mainMod, left , movefocus, l
        bind = $mainMod, right, movefocus, r
        bind = $mainMod, up   , movefocus, u
        bind = $mainMod, down , movefocus, d
        bind = $mainMod, H, movefocus,l
        bind = $mainMod, L, movefocus,r
        bind = $mainMod, K, movefocus,u
        bind = $mainMod, J, movefocus,d

        bind = $mainMod SHIFT, left , movewindow, l
        bind = $mainMod SHIFT, right, movewindow, r
        bind = $mainMod SHIFT, up   , movewindow, u
        bind = $mainMod SHIFT, down , movewindow, d

        bind = $mainMod SHIFT, H, movewindow,l
        bind = $mainMod SHIFT, L, movewindow,r
        bind = $mainMod SHIFT, K, movewindow,u
        bind = $mainMod SHIFT, J, movewindow,d

        # Switch workspaces with mainMod + [0-9]
        bind = $mainMod, ampersand, workspace, 1
        bind = $mainMod, eacute, workspace, 2
        bind = $mainMod, quotedbl, workspace, 3
        bind = $mainMod, apostrophe, workspace, 4
        bind = $mainMod, parenleft, workspace, 5
        bind = $mainMod, minus, workspace, 6
        bind = $mainMod, egrave, workspace, 7
        bind = $mainMod, underscore, workspace, 8
        bind = $mainMod, ccdella, workspace, 9
        bind = $mainMod, agrave, workspace, 10

        # Move active window to a workspace with mainMod + SHIFT + [0-9]
        bind = $mainMod SHIFT, ampersand, movetoworkspace, 1
        bind = $mainMod SHIFT, eacute, movetoworkspace, 2
        bind = $mainMod SHIFT, quotedbl, movetoworkspace, 3
        bind = $mainMod SHIFT, apostrophe, movetoworkspace, 4
        bind = $mainMod SHIFT, parenleft, movetoworkspace, 5
        bind = $mainMod SHIFT, minus, movetoworkspace, 6
        bind = $mainMod SHIFT, egrave, movetoworkspace, 7
        bind = $mainMod SHIFT, underscore, movetoworkspace, 8
        bind = $mainMod SHIFT, ccdella, movetoworkspace, 9
        bind = $mainMod SHIFT, agrave, movetoworkspace, 10

        bind = $mainMod CTRL, left, movecurrentworkspacetomonitor, l
        bind = $mainMod CTRL, right, movecurrentworkspacetomonitor, r

        # Example special workspace (scratchpad)
        bind = $mainMod, S, togglespecialworkspace, magic
        bind = $mainMod SHIFT, S, movetoworkspace, special:magic

        # Scroll through existing workspaces with mainMod + scroll
        bind = $mainMod, mouse_down, workspace, e+1
        bind = $mainMod, mouse_up, workspace, e-1

        # Move/resize windows with mainMod + LMB/RMB and dragging
        bindm = $mainMod, mouse:272, movewindow
        bindm = $mainMod, mouse:273, resizewindow

        # MEDIA keys
        bindl=,XF86AudioPlay,exec,${pkgs.playerctl}/bin/playerctl play-pause
        bind=,XF86AudioNext,exec,${pkgs.playerctl}/bin/playerctl next
        bind=,XF86AudioPrev,exec,${pkgs.playerctl}/bin/playerctl previous

        binde=,XF86AudioRaiseVolume,exec,${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+
        binde=,XF86AudioLowerVolume,exec,${pkgs.wireplumber}/bin/wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%-
        binde=,XF86AudioMute,exec,${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

        binde=SHIFT,XF86AudioRaiseVolume,exec,volumectl -mu +
        binde=SHIFT,XF86AudioLowerVolume,exec,volumectl -mu -
        binde=SHIFT,XF86AudioMute,exec,volumectl -m %
        binde=,XF86AudioMicMute,exec,volumectl -m toggle-mute

        binde=,XF86MonBrightnessDown,exec,lightctl down
        binde=,XF86MonBrightnessUp,exec,lightctl up


        ### Screen Shot ###

        # Screenshot a window
        bind = $mainMod, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m window --raw | ${pkgs.satty}/bin/satty -f - --action-on-enter save-to-clipboard --early-exit --copy-command wl-copy
        # Screenshot a monitor
        bind = , PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m output --raw | ${pkgs.satty}/bin/satty -f - --action-on-enter save-to-clipboard --early-exit --copy-command wl-copy
        # Screenshot a region
        bind = $mainMod SHIFT, PRINT, exec, ${pkgs.hyprshot}/bin/hyprshot -m region --raw | ${pkgs.satty}/bin/satty -f - --action-on-enter save-to-clipboard --early-exit --copy-command wl-copy

      '';
    };
  };
}
