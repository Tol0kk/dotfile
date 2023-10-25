{ pkgs, ... }: {
  kind = "Dark";
  kitty-theme = "Doom One";
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
      base00 = "#2a2e38"; # Darker
      base01 = "#353941";
      base02 = "#3f444a";
      base03 = "#74787C";
      base04 = "#AAABAD";
      base05 = "#DFDFDF";
      base06 = "#CDD1D7";
      base07 = "#bbc2cf"; # Lighter

      base08 = "#ff6c6b"; # Red
      base09 = "#F69573"; # Orange
      base0A = "#ECBE7B"; # Yellow
      base0B = "#98be65"; # Green
      base0C = "#46D9FF"; # Cyan
      base0D = "#51afef"; # Blue
      base0E = "#c678dd"; # Magenta
      base0F = "#9B8CE4"; # Violet

      base10 = "#ff6c6b"; # Bright Red
      base11 = "#F69573"; # Bright Orange
      base12 = "#ECBE7B"; # Bright Yellow
      base13 = "#98be65"; # Bright Green
      base14 = "#46D9FF"; # Bright Cyan
      base15 = "#51afef"; # Bright Blue
      base16 = "#c678dd"; # Bright Magenta
      base17 = "#9B8CE4"; # Bright Violet
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
      background-alt = base01;
      border1 = base0E;
      border2 = base0F;

      selection_foreground = base02;
      selection_background = base07;
      cursor = base07;
      cursor_text_color = base00;
      url_color = base0C;
      active_border_color = "#46D9FF";
      inactive_border_color = base02;
      bell_border_color = base09;
      active_tab_foreground = base00;
      active_tab_background = "#DFDFDF";
      inactive_tab_foreground = base02;
      inactive_tab_background = "#5B6268";
    };

}
