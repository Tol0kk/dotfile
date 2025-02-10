{
  pkgs,
  lib,
  config,
  libColor,
  ...
}:
with lib; let
  cfg = config.modules.zathura;
  inherit (libColor) toRGBA hexAndOpacityToRgba;
in {
  options.modules.zathura = {
    enable = mkOption {
      description = "Enable zathura";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    stylix.targets.zathura.enable = false;
    programs.zathura = {
      enable = true;
      mappings = {
        # Binding
        "<Right>" = "navigate next";
        "<Left>" = "navigate previous ";
        "<Up>" = "navigate previous ";
        "<Down>" = "navigate next ";
        "<C-x>" = "adjust_window best-fit";
        "<C-w>" = "zoom best-fit";
        "<A-c>" = "recolor";
      };
      options = with config.lib.stylix.colors; let
        base00_alpha = toRGBA (hexAndOpacityToRgba base00 config.stylix.opacity.terminal);
        base00_00 = toRGBA (hexAndOpacityToRgba base00 0.00);
        base02_30 = toRGBA (hexAndOpacityToRgba base02 0.30);
      in {
        # Config
        recolor = "true";
        selection-clipboard = "clipboard";
        vertical-center = "true";
        zoom-center = "true";

        # default-bg = "#${base00}";
        default-bg = base00_alpha;
        default-fg = "#${base01}";
        statusbar-fg = "#${base04}";
        statusbar-bg = base02_30;
        inputbar-bg = "#${base00}";
        inputbar-fg = "#${base07}";
        notification-bg = "#${base00}";
        notification-fg = "#${base07}";
        notification-error-bg = "#${base00}";
        notification-error-fg = "#${base08}";
        notification-warning-bg = "#${base00}";
        notification-warning-fg = "#${base08}";
        highlight-color = "#${base0A}";
        highlight-active-color = "#${base0D}";
        completion-bg = "#${base01}";
        completion-fg = "#${base0D}";
        completion-highlight-fg = "#${base07}";
        completion-highlight-bg = "#${base0D}";
        recolor-lightcolor = base00_00;
        recolor-darkcolor = "#${base06}";
      };
    };
  };
}
