{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.emacs;

in {
  options.modules.emacs = {
    enable = mkOption {
      description = "Enable emacs";
      type = types.bool;
      default = false;
    };
    distribution = mkOption {
      # TODO impl this
      description = "Select emacs distribution";
      # type = types.string;
      default = "";
    };
  };
  

  config = mkIf cfg.enable {
    # TODO add
    home.packages = with pkgs; [
      glib-networking
      fd
      texlive.combined.scheme-full

      #LSP
      rpm
      nodejs_20

      # GO
      gccgo
      gopls
      gore
      gotools
      gotest
      gomodifytags

      # NIX
      nixfmt

      #PYTHON
      black
      isort
      pipenv
      python311
      python311Packages.pyflakes
      python311Packages.nose
      python311Packages.pytest

      #RUST
      rust-analyzer
      cargo
      rustc

      #SH
      shfmt
      shellcheck

      #WEB
      html-tidy
      nodePackages.stylelint
      nodePackages.js-beautify

      #ZIG
      zig

      #JAVA
      clang-tools

      #MARKDOWN

      #vTERM
      cmake
      gnumake

    ];
    programs.emacs = {
      enable = true;
      package = pkgs.emacs29-pgtk;
    };
  };
}
