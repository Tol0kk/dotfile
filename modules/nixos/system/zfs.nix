# Improted
{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    ;
  cfg = config.modules.system.zfs;
in
{
  options.modules.system.zfs = {
    enable = mkEnableOption "Enable if the system is using zfs";
    encryption = mkEnableOption "zfs encryption" // {
      default = true;
    };
    zed = mkEnableOption "zfs event daemon";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      boot.zfs.requestEncryptionCredentials = cfg.encryption;
      boot.supportedFilesystems = [ "zfs" ];
      boot.initrd.kernelModules = [ "zfs" ];

      services.zfs = {
        autoScrub.enable = true;
        trim.enable = true;
      };
    })
  ];
}
