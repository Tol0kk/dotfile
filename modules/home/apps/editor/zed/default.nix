{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.apps.editor.zed;

  zed-wrap = pkgs.symlinkJoin {
    name = "zeditor-x11";
    paths = [ pkgs.zed-editor ];

    buildInputs = [ pkgs.makeWrapper ];

    postBuild = ''
      wrapProgram $out/bin/zeditor \
        --unset WAYLAND_DISPLAY
    '';
  };
in
{
  options.modules.apps.editor.zed = {
    enable = mkEnableOpt "Enable Zed";
  };

  config = mkIf cfg.enable {
    # nixGL.vulkan.enable = true;
    stylix.targets.zed.enable = false;
    # home.file = {
    # zed-keymap = {
    # source = ./keymap.json;
    # target = ".config/zed/keymap.json";
    # };
    # zed-settings = {
    # source = ./settings.json;
    # target = ".config/zed/settings.json";
    # };
    # };
    #
    home.file.".config/zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/apps/editor/zed/settings.json";
    home.file.".config/zed/keymap.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/apps/editor/zed/keymap.json";
    programs.zed-editor = {
      package = zed-wrap;
      enable = true;
      extensions = ["nix" "toml" "make"];
      # userSettings = {
      #   hour_format = "hour24";
      #   auto_update = false;
      #   load_direnv = "shell_hook";
      #   base_keymap = "VSCode";
      #   show_whitespaces = "all";
      #   assistant = {
      #     enabled = true;
      #     version = "2";
      #     default_open_ai_model = null;
      #     default_model = {
      #       provider = "zed.dev";
      #       model = "claude-3-5-sonnet-latest";
      #     };
      #   };
      #   node = {
      #     path = lib.getExe pkgs.nodejs;
      #     npm_path = lib.getExe' pkgs.nodejs "npm";
      #   };
      #   lsp = {
      #     rust-analyzer = {
      #       binary = {
      #         path = "rust-analyzer";
      #       };
      #     };
      #     nix = {
      #       binary = {
      #         path_lookup = true;
      #       };
      #     };

      #     elixir-ls = {
      #       binary = {
      #         path_lookup = true;
      #       };
      #       settings = {
      #         dialyzerEnabled = true;
      #       };
      #     };
      #   };
      # };
    };
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/plain" = "dev.zed.Zed.desktop";
        "text/english" = "dev.zed.Zed.desktop";

        "text/markdown" = "dev.zed.Zed.desktop";
        "text/x-markdown" = "dev.zed.Zed.desktop";

        "text/html" = "zen-beta.desktop";
        "x-scheme-handler/http" = "zen-beta.desktop";
        "x-scheme-handler/https" = "zen-beta.desktop";
        "x-scheme-handler/about" = "zen-beta.desktop";
        "x-scheme-handler/unknown" = "zen-beta.desktop";

        # Web-related file types
        "application/x-extension-htm" = "zen-beta.desktop";
        "application/x-extension-html" = "zen-beta.desktop";
      };
    };
  };
}
