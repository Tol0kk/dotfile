{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.kitty;
  themecfg = config.modules.theme;
  colorScheme = config.modules.theme.colorScheme;
  inherit (lib.strings) floatToString;
in
{
  options.modules.kitty = {
    enable = mkOption {
      description = "Enable kitty";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font.package = themecfg.font.package;
      font.size = 11;
      font.name = themecfg.font.name;
      # theme = themecfg.kitty-theme;
      settings = {
        confirm_os_window_close = 0;
        background_opacity = floatToString themecfg.base_opacity;
        enable_audio_bell = false;

        "map f1" = "toggle_marker iregex 1 ERROR 2 WARNING 2 FAIL 2 FAILED 2 UNABLE 3 DEPRECATED ";

        ## Theme 
        foreground = colorScheme.foreground;
        background = colorScheme.background;
        selection_foreground = colorScheme.selection_foreground;
        selection_background = colorScheme.selection_background;
        cursor = colorScheme.cursor;
        cursor_text_color = colorScheme.cursor_text_color;
        active_border_color = colorScheme.active_border_color;
        inactive_border_color = colorScheme.inactive_border_color;
        active_tab_foreground = colorScheme.active_tab_foreground;
        active_tab_background = colorScheme.active_tab_background;
        inactive_tab_foreground = colorScheme.inactive_tab_foreground;
        inactive_tab_background = colorScheme.inactive_tab_background;
        bell_border_color = colorScheme.bell_border_color;
        url_color = colorScheme.url_color;


        ## Mark
        # mark 1: urgent (Error) 
        # mark 2: medium (Warning) 
        # mark 3: common (Search, not dangerous) 
        mark1_foreground = colorScheme.base00;
        mark1_background = colorScheme.red;
        mark2_foreground = colorScheme.base00;
        mark2_background = colorScheme.yellow;
        mark3_foreground = colorScheme.cyan;
        mark3_background = colorScheme.background;

        # black
        color0 = colorScheme.base00;
        color8 = colorScheme.base02;

        # red
        color1 = colorScheme.red;
        color9 = colorScheme.red;

        # green
        color2 = colorScheme.green;
        color10 = colorScheme.green;

        # yellow
        color3 = colorScheme.yellow;
        color11 = colorScheme.yellow;

        # blue
        color4 = colorScheme.blue;
        color12 = colorScheme.blue;

        # magenta
        color5 = colorScheme.magenta;
        color13 = colorScheme.magenta;

        # cyan
        color6 = colorScheme.cyan;
        color14 = colorScheme.cyan;

        # white
        color7 = colorScheme.base05;
        color15 = colorScheme.base07;
      };
    };
  };
}
