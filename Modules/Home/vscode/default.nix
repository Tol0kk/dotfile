{ pkgs
, lib
, config
, ...
}:

with lib;
let
  cfg = config.modules.vscode;
in
{
  options.modules.vscode = {
    enable = mkOption {
      description = "Enable Visual Studio Code.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.nixpkgs-fmt ];
    stylix.targets.vscode.enable = false;
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;
      mutableExtensionsDir = true;
      extensions = with pkgs.vscode-extensions; [
        pkief.material-product-icons
        llvm-vs-code-extensions.vscode-clangd
        rust-lang.rust-analyzer
        bungcip.better-toml
        tamasfe.even-better-toml
        serayuzgur.crates
        ziglang.vscode-zig
        ms-python.python
        ms-toolsai.jupyter
        jnoortheen.nix-ide
        eamodio.gitlens
        pkief.material-icon-theme
	soerenuhrbach.vscode-deepl
      ];
      userSettings = {
        "files.autoSave" = "onFocusChange";
        "[nix]"."editor.tabSize" = 2;
        "workbench"."colorTheme" = "Default Dark+";
        "breadcrumbs.enabled" = false;
        "editor.stickyScroll.enabled" = false;
        "editor.minimap.enabled" = false;
        "workbench.productIconTheme" = "material-product-icons";
        "workbench.iconTheme" = "material-icon-theme";
        "explorer.confirmDragAndDrop" = false;
        "window.menuBarVisibility" = "toggle";
        "git.confirmSync" = false;
        "explorer.confirmDelete" = false;


        # Nix IDE
        # "nix.formatterPath" = "nixfmt";
        # "nix" = {
        # "enableLanguageServer" = true;
        # "serverPath" = "nil";
        # "serverSettings.nil.formatting.command" = [ "nixpkgs-fmt" ];
        # };
      };


      globalSnippets = (import ./Snippets/globalSnippets.nix);
      languageSnippets = (import ./Snippets/languageSnippets.nix);
      keybindings = [
        # TODO place it into one file.
        {
          key = "ctrl+°";
          command = "editor.action.clipboardCopyAction";
          when = "textInputFocus";
        }
      ];
    };
  };
}
