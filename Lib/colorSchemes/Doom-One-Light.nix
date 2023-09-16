{ pkgs, ... }: {
  kind = "Light";
  kitty-theme = "Doom One Light";
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
}
