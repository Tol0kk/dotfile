{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.kitty;
  themecfg = config.modules.theme;
in
{
  options.modules.kitty = {
    enable = mkOption {
      description = "Enable kitty";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font.package = themecfg.font.package;
      font.size = 11;
      font.name = themecfg.font.name;
      theme = themecfg.kitty-theme;
      settings = {
        confirm_os_window_close = 0;
        background_opacity = "0.60";
      };
    };
  };
}
