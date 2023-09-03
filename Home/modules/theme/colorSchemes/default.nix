{ pkgs, ... }: {
  Doom-One = {
    kitty-theme = "Doom One";
    kind = "Dark";
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
  };
  Doom-One-Light = {
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
  };
  Catppuccin-Mocha = {
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
  };
}
