{
  flake.homeModules.vscode =
    {
      pkgs,
      lib,
      config,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    {
      home.packages = [
        pkgs.alejandra
        pkgs.bruno
      ];
      stylix.targets.vscode.enable = false;
      programs.vscode = {
        enable = true;
        package = pkgs.vscodium;
        mutableExtensionsDir = true;
        profiles.default = {
          enableExtensionUpdateCheck = true;
          enableUpdateCheck = true;
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
            "jupyter.askForKernelRestart" = false;
            "editor.inlineSuggest.suppressSuggestions" = true;
            "qt-qml.qmlls.useQmlImportPathEnvVar" = true;
            "qmlFormat.extraArguments" = [
              "-w 2"
            ];

            "nix" = {
              "formatterPath" = "alejandra";
              "enableLanguageServer" = true;
              "serverSettings" = {
                "nil" = {
                  "formatting" = {
                    "command" = [ "alejandra" ];
                  };
                };
              };
            };
          };
          globalSnippets = import ./_snippets/globalSnippets.nix;
          languageSnippets = import ./_snippets/languageSnippets.nix;
          keybindings = [
            {
              key = "ctrl+°";
              command = "editor.action.clipboardCopyAction";
              when = "textInputFocus";
            }
          ];
          extensions =
            with pkgs.vscode-extensions;
            [
              pkief.material-product-icons
              llvm-vs-code-extensions.vscode-clangd # Clangd
              twxs.cmake # Cmake
              rust-lang.rust-analyzer # Rust analyzer
              vadimcn.vscode-lldb # CodeLLDB
              tamasfe.even-better-toml # Even better TOML
              fill-labs.dependi # Dependi (Crates Dependency management)
              ziglang.vscode-zig
              mhutchie.git-graph # Git graph
              # ms-python.python
              ms-toolsai.jupyter
              jnoortheen.nix-ide
              pkief.material-icon-theme
              davidlday.languagetool-linter
              golang.go
              aaron-bond.better-comments # Better Comments

              # DSL Tools
              hashicorp.terraform

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
        };
      };
    };
}
