{ lib
, config
, ...
}:
with lib;
let
  cfg = config.modules.git;
in
{
  options.modules.git = {
    enable = mkOption {
      description = "Enable Git";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      diff-so-fancy.enable = true;
      userEmail = "titouan.le.dilavrec@gmail.com";
      userName = "Tol0kk";
      extraConfig = {
        commit.gpgsign = true;
        gpg.format = "ssh";
        user.signingkey = "~/.ssh/id_ed25519.pub";
        pull.rebase = false;
        init.defaultBranch = "main";
      };
    };
  };
}
