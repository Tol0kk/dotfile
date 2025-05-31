{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.editor.zed;
in {
  options.modules.apps.editor.zed = {
    enable = mkEnableOpt "Enable Zed";
  };

  config = mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      extensions = ["nix" "toml" "elixir" "make"];
      userSettings = {
        hour_format = "hour24";
        auto_update = false;
        load_direnv = "shell_hook";
        base_keymap = "VSCode";
        show_whitespaces = "all";
        assistant = {
          enabled = true;
          version = "2";
          default_open_ai_model = null;
          default_model = {
            provider = "zed.dev";
            model = "claude-3-5-sonnet-latest";
          };
        };
        node = {
          path = lib.getExe pkgs.nodejs;
          npm_path = lib.getExe' pkgs.nodejs "npm";
        };
        lsp = {
          rust-analyzer = {
            binary = {
              path = "rust-analyzer";
            };
          };
          nix = {
            binary = {
              path_lookup = true;
            };
          };

          elixir-ls = {
            binary = {
              path_lookup = true;
            };
            settings = {
              dialyzerEnabled = true;
            };
          };
        };
      };
    };
  };
}
