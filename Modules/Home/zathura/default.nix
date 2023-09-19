{ pkgs, lib, config, color, ... }:
with lib;
let
  cfg = config.modules.zathura;
  themecfg = config.modules.theme;
  colorScheme = config.modules.theme.colorScheme;
in
{
  options.modules.zathura = {
    enable = mkOption {
      description = "Enable zathura";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      zathura
    ];
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
      options = with colorScheme; {
        # Config
        recolor = "true";
        selection-clipboard = "clipboard";
        vertical-center = "true";
        zoom-center = "true";

        # Theme
        default-fg = base07;
        default-bg = color.toRGBA (color.hexAndOpacityToRgba base00 themecfg.base_opacity);

        completion-bg = base01;
        completion-fg = base07;
        completion-highlight-bg = base03;
        completion-highlight-fg = base07;
        completion-group-bg = base01;
        completion-group-fg = cyan;

        statusbar-fg = base07;
        statusbar-bg = base01;

        notification-bg = base01;
        notification-fg = base07;
        notification-error-bg = base01;
        notification-error-fg = red;
        notification-warning-bg = base01;
        notification-warning-fg = yellow;

        inputbar-fg = base07;
        inputbar-bg = base01;

        recolor-lightcolor = color.toRGBA (color.hexAndOpacityToRgba base00 0.00);

        index-fg = base07;
        index-bg = base00;
        index-active-fg = base07;
        index-active-bg = base01;

        render-loading-bg = base00;
        render-loading-fg = base07;

        highlight-color = base03;
        highlight-fg = magenta;
        highlight-active-color = magenta;
      };
    };
  };
}
