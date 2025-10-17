{
  lib,
  config,
  libCustom,
  pkgs,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.apps.thunar;
in
{
  options.modules.apps.thunar = {
    enable = mkEnableOpt "Enable Thunar";
  };

  config = mkIf cfg.enable {
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-volman
      thunar-media-tags-plugin
      thunar-vcs-plugin
      thunar-archive-plugin
    ];
    programs.thunar.enable = true;
  };
}
