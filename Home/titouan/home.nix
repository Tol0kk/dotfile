{ self, pkgs, config, ... }:
{
  modules = {
    kitty.enable = true;
    vscode.enable = true;
    git.enable = true;
    shell.enable = true;
    emails.enable = true;
    emacs.enable = true;
  };

   home.sessionVariables = {
    MY_BROWSER = "${pkgs.firefox}/bin/firefox"; # TODO: move to browser config file later
  };

  services.amberol.enable = true;
}