{ pkgs, lib, config, pkgs-unstable, ... }:
with lib;
let cfg = config.modules.emacs;

in {
  options.modules.emacs = {
    enable = mkOption {
      description = "Enable Emacs";
      type = types.bool;
      default = false;
    };
  };

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
