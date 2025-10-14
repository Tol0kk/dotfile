{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.term.wezterm;
in {
  options.modules.apps.term.wezterm = {
    enable = mkEnableOpt "Enable Anyrun";
  };

  config = mkIf cfg.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        return {
          font = wezterm.font("Maple Mono"),
          font_size = 11.0,
          hide_tab_bar_if_only_one_tab = true,
          color_scheme = 'Gruvbox dark, hard (base16)',
          window_close_confirmation = 'NeverPrompt',
          default_prog = { "fish" },
        }
      '';
    };
  };
}
#          default_prog = { "fish", "-c", "zellij" },

