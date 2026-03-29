{
  flake.nixosModules.zfs =
    {
      config,
      lib,
      ...
    }:
    let
      inherit (lib)
        mkEnableOption
        ;
      cfg = config.modules.system.zfs;
    in
    {
      options.modules.system.zfs = {
        encryption = mkEnableOption "zfs encryption" // {
          default = true;
        };
        zed = mkEnableOption "zfs event daemon"; # TODO
      };

      config = {

        boot.zfs.requestEncryptionCredentials = cfg.encryption;
        boot.supportedFilesystems = [ "zfs" ];
        boot.initrd.kernelModules = [ "zfs" ];

        services.zfs = {
          autoScrub.enable = true;
          trim.enable = true;
        };
      };
    };
}
