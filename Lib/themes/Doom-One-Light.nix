{ pkgs, ... }: {
  kind = "Light";
  kitty-theme = "Doom One Light";
  base_opacity = "0.60";
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
    };
  };
  colorScheme =
    let
      base00 = "#383a42"; # Darker
      base01 = "#67696E";
      base02 = "#97989B";
      base03 = "#c6c7c7";
      base04 = "#dfdfdf";
      base05 = "#f0f0f0";
      base06 = "#F5F5F5";
      base07 = "#fafafa"; # Lighter

      base08 = "#e45649"; # Red
      base09 = "#BE5F25"; # Orange
      base0A = "#986801"; # Yellow
      base0B = "#50a14f"; # Green
      base0C = "#0184bc"; # Cyan
      base0D = "#4078f2"; # Blue
      base0E = "#b751b6"; # Magenta
      base0F = "#7C65D4"; # Violet
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

      foreground = base01;
      background = "#fafafa";
      selection_foreground = base01;
      selection_background = "#dfdfdf";
      cursor = base01;
      cursor_text_color = "#fafafa";
      url_color = base0C;
      active_border_color = "#0184bc";
      inactive_border_color = base02;
      bell_border_color = base09;
      active_tab_foreground = "#fafafa";
      active_tab_background = "#383a42";
      inactive_tab_foreground = base02;
      inactive_tab_background = "#5B6268";
    };

}
