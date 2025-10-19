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
    programs.xfconf.enable = true;
    programs.thunar.enable = true;
    services.gvfs.enable = true; # Mount, trash, and other functionalities

    # Thumbnails
    services.tumbler.enable = true; # Thumbnail support for images
    environment.systemPackages = with pkgs; [
      webp-pixbuf-loader
      ffmpegthumbnailer
      gnome-epub-thumbnailer
      gnome-font-viewer
      f3d
      xarchiver
    ];
  };
}
