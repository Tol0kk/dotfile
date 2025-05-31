{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.misc.mpv;
in {
  options.modules.apps.misc.mpv = {
    enable = mkEnableOpt "Enable MPV";
  };

  # TODO configure
  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
    };
  };
}
