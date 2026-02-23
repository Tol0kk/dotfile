{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  inherit (lib)
    mkOption
    assertMsg
    any
    unique
    optionals
    hasPrefix
    mkIf
    mkMerge
    mkEnableOption
    ;
  inherit (lib.types) listOf str;
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

      fileSystems = {
        # "/" =  {
        #   device = "rppol/nixos/root";
        #   fsType = "zfs";
        #   neededForBoot = true;
        # };

        # "/home" = {
        #   device = "nixos/home";
        #   fsType = "zfs";
        #   neededForBoot = true;
        # };

        # "/nix" = {
        #   device = "nixos/nix";
        #   fsType = "zfs";
        #   neededForBoot = true;
        # };

        # "/var/log" = {
        #   device = "nixos/var/log";
        #   fsType = "zfs";
        # };

        # "/var/lib" = {
        #   device = "nixos/var/lib";
        #   fsType = "zfs";
        # };

        # "/persist" = {
        #   device = "nixos/persist";
        #   fsType = "zfs";
        #   neededForBoot = true;
        # };
      };
    })
  ];
}
