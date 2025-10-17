{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.apps.misc.thunar;
in
{
  options.modules.apps.misc.thunar = {
    enable = mkEnableOpt "Enable Thunar Actions";
  };

  config = mkIf cfg.enable {
    home.file.".config/Thunar/uca.xml".source =
      config.lib.file.mkOutOfStoreSymlink "${config.dotfiles}/modules/home/apps/misc/thunar/actions.xml";
    modules.defaults.file_manager = "thunar";
  };
}
