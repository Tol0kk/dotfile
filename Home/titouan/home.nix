{ self, pkgs, config, ... }:
{
  modules = {
    kitty.enable = true;
    vscode.enable = true;
    git.enable = true;
    shell.enable = true;
    emails.enable = true;
    emacs.enable = true;
    hypr.enable = true;
    anyrun.enable = true;
    zathura.enable = true;
  };

  home.sessionVariables = {
    MY_BROWSER = "${pkgs.firefox}/bin/firefox"; # TODO: move to browser config file later
  };

  home.packages = with pkgs;[
    pkgs.grim
    pkgs.slurp
    pkgs.swappy
    wl-clipboard

    pkgs.swaynotificationcenter
    pkgs.libnotify
    pkgs.jq
    pkgs.ags
          gtksourceview
      webkitgtk
      accountsservice
      pkgs.libdbusmenu-gtk3
  ];

  services.amberol.enable = true;
}
