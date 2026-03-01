# Importde
{
  lib,
  libCustom,
  config,
  pkgs,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.hardware.filesystems.ntfs;
in
{
  options.modules.hardware.filesystems.ntfs = {
    enable = mkEnableOpt "Enable ntfs support";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      ntfs3g
    ];
    boot.supportedFilesystems = [ "ntfs" ];
  };
}
