{
  flake.homeModules.wezterm =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
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
