# USAGE in your configuration.nix.
# Update devices to match your hardware.
# {
#  imports = [ ./disko-config.nix ];
#  disko.devices.disk.main.device = "/dev/sda";
# }
let
  root_pool = "rpool";
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "${root_pool}";
              };
            };
          };
        };
      };
    };
    zpool = {
      "${root_pool}" = {
        type = "zpool";
        rootFsOptions = {
          acltype = "posixacl";
          atime = "off";
          compression = "zstd";
          mountpoint = "none";
          xattr = "sa";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
        };
        options = {
          autotrim = "on";
          ashift = "13";
        };
        datasets = {
          "nixos" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "nixos/root" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/";
            options."com.sun:auto-snapshot" = "false"; # Don't need snapshot on root since it is handle by nix
            postCreateHook = "zfs list -t snapshot -H -o name | grep -E '^${root_pool}/nixos/root@blank$' || zfs snapshot ${root_pool}/nixos/root@blank";
          };
          "nixos/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
            options.mountpoint = "legacy";
            # Don't need snapshot on /nix since it is read-only and fully reproducible from other files.
            options."com.sun:auto-snapshot" = "false";
          };
          "nixos/home" = {
            type = "zfs_fs";
            mountpoint = "/home";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "true"; # We want snapshot for a safer storage of home files
          };
          "nixos/persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "legacy";
            options."com.sun:auto-snapshot" = "true"; # Same as home files since it is important files
          };
          "nixos/var" = {
            type = "zfs_fs";
            options.mountpoint = "none";
          };
          "nixos/var/log" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var/log";
            options."com.sun:auto-snapshot" = "true";
          };
          "nixos/var/lib" = {
            type = "zfs_fs";
            options.mountpoint = "legacy";
            mountpoint = "/var/lib";
            options."com.sun:auto-snapshot" = "true";
          };
        };
      };
    };
  };
}
