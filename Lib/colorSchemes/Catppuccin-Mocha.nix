{ pkgs, ... }: {
  kind = "Light";
  kitty-theme = "Catppuccin-Mocha";
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
}
