{
  flake.homeModules.alacritty =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.alacritty = {
        enable = true;
        theme = "gruvbox_dark";
      };
      modules.defaults.terminal = lib.getExe config.programs.alacritty.package;
    };
}
