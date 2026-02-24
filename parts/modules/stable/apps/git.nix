{
  flake.homeModules.git =
    { ... }:
    {
      programs.git = {
        enable = true;
        signing.signByDefault = true;
        settings = {
          user.email = "personal@tolok.org";
          user.name = "Tol0kk";
          commit.gpgsign = true;
          gpg.format = "ssh";
          submodule.recurse = true;
          user.signingkey = "~/.ssh/id_ed25519.pub";
          pull.rebase = false;
          init.defaultBranch = "main";
        };
      };
      programs.diff-so-fancy.enable = true;
      programs.diff-so-fancy.enableGitIntegration = true;
    };
}
