{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.dunst;

in {
  options.modules.dunst = {
    enable = mkOption {
      description = "Enable dunst";
      type = types.bool;
      default = false;
    };
  };

  # TODO use colors.scheme.doom
  config = mkIf cfg.enable {
    home.packages = [ pkgs.libnotify ]; # Dependency
    services.dunst = {
      enable = true;
      iconTheme = {
        # Icons
        name = "Papirus Dark";
        package = pkgs.papirus-icon-theme;
        size = "16x16";
      };
      # settings = with colors.scheme.doom; {
      settings = {
        # Settings
        global = {
          monitor = 0;
          # geometry [{width}x{height}][+/-{x}+/-{y}]
          # geometry = "600x50-50+65";
          follow = "mouse";
          width = "(230,300)";
          height = 300;
          origin = "top-right";
          offset = "20x20";
          progress_bar = true;
          progress_bar_height = 10;
          progress_bar_frame_width = 1;
          progress_bar_min_width = 150;
          progress_bar_max_width = 300;
          indicate_hidden = "yes";
          transparency = 10; # X11 only
          separator_height = 2;
          padding = 8;
          horizontal_padding = 8;
          text_icon_padding = 0;
          frame_width = 3;
          frame_color = "#ffffff00";
          separator_color = "frame";
          sort = true;
          idle_threshold = 120;
          font = "FiraCode Nerd Font 10";
          line_height = 3;
          markup = "full";
          format = "<b>%s</b>\\n%b";
          alignment = "left";
          vertical_alignment = "center";
          show_age_threshold = 20;
          ellipsize = "middle";
          ignore_newline = "no";
          stack_duplicates = true;
          hide_duplicate_count = true;
          show_indicators = "yes";
          icon_position = "left";
          min_icon_size = 0;
          max_icon_size = 32;
          dmenu = "/etc/profiles/per-user/titouan/bin/rofi -p dunst:";
          browser = "/etc/profiles/per-user/titouan/bin/brave";
          corner_radius = 15;
          ignore_dbusclose = true;
          mouse_left_click = "do_action, open_url";
          mouse_middle_click = "close_all";
          mouse_right_click = "close_current";
          # startup_notification = false;
        };
        experimental = { per_monitor_dpi = true; };
        # urgency_low = {
        #   # Colors
        #   background = "#${bg}da";
        #   foreground = "#${text}";
        #   timeout = 4;
        # };
        # urgency_normal = {
        #   background = "#${bg}da";
        #   foreground = "#${text}";
        #   timeout = 4;
        # };
        # urgency_critical = {
        #   background = "#${bg}da";
        #   foreground = "#${text}";
        #   frame_color = "#${red}";
        #   timeout = 10;
        # };
      };
    };
  };
}
