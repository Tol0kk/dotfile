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

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "audio/mp4" = "mpv.desktop";
        "video/mp4" = "mpv.desktop";
        "video/mp4v-es" = "mpv.desktop";
        "application/x-extension-mp4" = "mpv.desktop";
        "video/mkv" = "mpv.desktop";
        "video/mpeg" = "mpv.desktop";
        "video/mpeg-system" = "mpv.desktop";
        "video/x-mpeg" = "mpv.desktop";
        "video/x-mpeg-system" = "mpv.desktop";
        "video/x-mpeg2" = "mpv.desktop";
      };
    };
  };
}
