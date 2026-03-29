{
  flake.homeModules.zed =
    {
      pkgs,
      lib,
      config,
      libCustom,
      isPure,
      ...
    }:
    with lib;
    with libCustom;
    {
      # nixGL.vulkan.enable = true;
      stylix.targets.zed.enable = false;
      home.file.".config/zed/settings.json".source =
        mkSource isPure ./settings.json
          "${config.dotfiles}/modules/home/apps/editor/zed/settings.json";
      home.file.".config/zed/keymap.json".source =
        mkSource isPure ./keymap.json
          "${config.dotfiles}/modules/home/apps/editor/zed/keymap.json";
      programs.zed-editor = {
        # package = zed-wrap;
        enable = true;
      };
      home.packages = with pkgs; [ package-version-server ];
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
