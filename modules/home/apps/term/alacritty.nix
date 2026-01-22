{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.term.alacritty;
in {
  options.modules.apps.term.alacritty = {
    enable = mkEnableOpt "Enable Anyrun";
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      theme = "gruvbox_dark";
    };
    modules.defaults.terminal = lib.getExe config.programs.alacritty.package;
  };
}
