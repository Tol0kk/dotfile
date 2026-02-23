{
  pkgs,
  lib,
  config,
  pkgs-unstable,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.apps.editor.emacs;
in
{
  options.modules.apps.editor.emacs = {
    enable = mkEnableOpt "Enable Emacs";
  };

  # TODO check if usefull (nixos module)
  config = mkIf cfg.enable {
    home.packages = [
      pkgs-unstable.tree-sitter-grammars.tree-sitter-typst
      pkgs.diffsitter.out
    ];
    home.file = {
      # tree-sitter subdirectory of the directory specified by user-emacs-directory
      ".config/emacs/.local/cache/tree-sitter".source =
        "${pkgs-unstable.emacsPackages.treesit-grammars.with-all-grammars}/lib";
    };
    programs.emacs = {
      enable = true;
      package = pkgs-unstable.emacs;
      extraPackages = epkgs: [ epkgs.treesit-grammars.with-all-grammars ];
    };
  };
}
