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
in
{
  options.modules.apps.editor.zed = {
    enable = mkEnableOpt "Enable Zed";
  };

  config = mkIf cfg.enable {
    # nixGL.vulkan.enable = true;
    stylix.targets.zed.enable = false;
    home.file.".config/zed/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/apps/editor/zed/settings.json";
    home.file.".config/zed/keymap.json".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/apps/editor/zed/keymap.json";
    programs.zed-editor = {
      # package = zed-wrap;
      enable = true;
    };
    modules.defaults.editor = "${config.programs.zed-editor.package}/bin/zeditor";
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
