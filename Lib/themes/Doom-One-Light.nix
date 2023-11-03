{ pkgs, ... }: {
  kind = "Light";
  kitty-theme = "Doom One Light";
  base_opacity = 0.65;
  font = {
    name = "Cascadia Code";
    package = pkgs.cascadia-code;
  };
  gtk = {
    theme = {
      name = "Sweet-Ambar-Blue";
      package = pkgs.sweet;
    };
    iconTheme = {
      name = "Paper";
      package = pkgs.paper-icon-theme;
    };
    cursorTheme = {
      name = "phinger-cursors";
      package = pkgs.phinger-cursors;
      size = 28;
    };
  };
  colorScheme = let
    base07 = "#383a42"; # Darker
    base06 = "#67696E";
    base05 = "#97989B";
    base04 = "#c6c7c7";
    base03 = "#dfdfdf";
    base02 = "#f0f0f0";
    base01 = "#F5F5F5";
    base00 = "#fafafa"; # Lighter

    base08 = "#e45649"; # Red
    base09 = "#BE5F25"; # Orange
    base0A = "#986801"; # Yellow
    base0B = "#50a14f"; # Green
    base0C = "#0184bc"; # Cyan
    base0D = "#4078f2"; # Blue
    base0E = "#b751b6"; # Magenta
    base0F = "#7C65D4"; # Violet

    base10 = "#e45649"; # Bright Red
    base11 = "#BE5F25"; # Bright Orange
    base12 = "#986801"; # Bright Yellow
    base13 = "#50a14f"; # Bright Green
    base14 = "#0184bc"; # Bright Cyan
    base15 = "#4078f2"; # Bright Blue
    base16 = "#b751b6"; # Bright Magenta
    base17 = "#7C65D4"; # Bright Violet
  in {
    inherit base00 base01 base02 base03 base04 base05 base06 base07 base08
      base09 base0A base0B base0C base0D base0E base0F;

    red = base08;
    orange = base09;
    yellow = base0A;
    green = base0B;
    cyan = base0C;
    blue = base0D;
    magenta = base0E;
    violet = base0F;

    foreground = base07;
    background = base01;
    background-alt = base02;
    border1 = base0E;
    border2 = base0F;

    selection_foreground = base07;
    selection_background = "#dfdfdf";
    cursor = base06;
    cursor_text_color = "#fafafa";
    url_color = base0C;
    active_border_color = "#0184bc";
    inactive_border_color = base07;
    bell_border_color = base09;
    active_tab_foreground = "#fafafa";
    active_tab_background = "#383a42";
    inactive_tab_foreground = base05;
    inactive_tab_background = "#5B6268";
  };

}
