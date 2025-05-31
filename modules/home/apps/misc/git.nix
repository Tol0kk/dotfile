{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.misc.git;
in {
  options.modules.apps.misc.git = {
    enable = mkEnableOpt "Enable Git";
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      diff-so-fancy.enable = true;
      # difftastic.enable = true;
      userEmail = "personal@tolok.org";
      userName = "Tol0kk";
      signing.signByDefault = true;
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        submodule.recurse = true;
        user.signingkey = "~/.ssh/id_ed25519.pub";
        pull.rebase = false;
        init.defaultBranch = "main";
      };
    };
  };
}
