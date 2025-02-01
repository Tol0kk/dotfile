{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.vscode;
in {
  options.modules.vscode = {
    enable = mkOption {
      description = "Enable Visual Studio Code.";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.alejandra pkgs.bruno];
    stylix.targets.vscode.enable = false;
    programs.vscode = {
      enable = true;
      package = pkgs.vscodium;
      enableExtensionUpdateCheck = true;
      enableUpdateCheck = true;
      mutableExtensionsDir = true;
      extensions = with pkgs.vscode-extensions;
        [
          pkief.material-product-icons
          llvm-vs-code-extensions.vscode-clangd
          rust-lang.rust-analyzer
          bungcip.better-toml
          tamasfe.even-better-toml
          serayuzgur.crates
          ziglang.vscode-zig
          # ms-python.python
          ms-toolsai.jupyter
          jnoortheen.nix-ide
          eamodio.gitlens
          pkief.material-icon-theme
          davidlday.languagetool-linter
          golang.go
          aaron-bond.better-comments

          # Java
          vscjava.vscode-java-test
          vscjava.vscode-maven
          vscjava.vscode-java-dependency
          vscjava.vscode-java-debug
          vscjava.vscode-gradle
          redhat.java
          redhat.vscode-xml
          redhat.vscode-yaml
          redhat.ansible

          # Web
          angular.ng-template
          ecmel.vscode-html-css
          esbenp.prettier-vscode
          svelte.svelte-vscode

          golang.go

          # soerenuhrbach.vscode-deepl # Not yet available on nixpkgs
        ]
        ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "bruno";
            publisher = "bruno-api-client";
            version = "3.1.0";
            sha256 = "sha256-jLQincxitnVCCeeaoX0SOuj5PJyR7CdOjK4Kl52ShlA=";
          }
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
        "redhat.telemetry.enabled" = false;

        "nix" = {
          "formatterPath" = "alejandra";
          "enableLanguageServer" = true;
          "serverSettings" = {
            "nil" = {
              "formatting" = {
                "command" = ["alejandra"];
              };
            };
          };
        };
      };

      globalSnippets = import ./Snippets/globalSnippets.nix;
      languageSnippets = import ./Snippets/languageSnippets.nix;
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
