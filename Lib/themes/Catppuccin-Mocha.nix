{ pkgs, ... }: {
  kind = "Light";
  kitty-theme = "Catppuccin-Mocha";
  base_opacity = 0.65;
  font = {
    name = "Cascadia Code";
    package = pkgs.cascadia-code;
  };
  gtk = {
    theme = {
      name = "Sweet-mars";
      package = pkgs.sweet;
    };
    iconTheme = {
      name = "Paper";
      package = pkgs.paper-icon-theme;
    };
    cursorTheme = {
      name = "phinger-cursors";
      package = pkgs.phinger-cursors;
    };
  };
  colorScheme =
    let
      base00 = "#1E1E2E"; # Darker
      base01 = "#4F5165";
      base02 = "#585B70";
      base03 = "#72768D";
      base04 = "#8C92AB";
      base05 = "#A6ADC8";
      base06 = "#B0B8D3";
      base07 = "#CDD6F4"; # Lighter

      base08 = "#F38BA8"; # Red
      base09 = "#F6B7AC"; # Orange
      base0A = "#F9E2AF"; # Yellow
      base0B = "#A6E3A1"; # Green
      base0C = "#94E2D5"; # Cyan
      base0D = "#89B4FA"; # Blue
      base0E = "#F5C2E7"; # Magenta
      base0F = "#BFBBF1"; # Violet

      base10 = "#F38BA8"; # Bright Red
      base11 = "#F6B7AC"; # Bright Orange
      base12 = "#F9E2AF"; # Bright Yellow
      base13 = "#A6E3A1"; # Bright Green
      base14 = "#94E2D5"; # Bright Cyan
      base15 = "#89B4FA"; # Bright Blue
      base16 = "#F5C2E7"; # Bright Magenta
      base17 = "#BFBBF1"; # Bright Violet
    in
    {
      inherit
        base00 base01 base02 base03
        base04 base05 base06 base07
        base08 base09 base0A base0B
        base0C base0D base0E base0F;

      red = base08;
      orange = base09;
      yellow = base0A;
      green = base0B;
      cyan = base0C;
      blue = base0D;
      magenta = base0E;
      violet = base0F;

      foreground = base07;
      background = base00;
      selection_foreground = base00;
      selection_background = base06;
      cursor = base06;
      cursor_text_color = base00;
      url_color = base06;
      active_border_color = base04;
      inactive_border_color = base02;
      bell_border_color = "#F9E2AF";
      active_tab_foreground = "#11111B";
      active_tab_background = "#CBA6F7";
      inactive_tab_foreground = base07;
      inactive_tab_background = "#181825";
    };

}
