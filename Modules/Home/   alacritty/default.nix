{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.alacritty;
  themecfg = config.modules.theme;
in
{
  options.modules.alacritty = {
    enable = mkOption {
      description = "Enable alacritty";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
    };
  };
}
