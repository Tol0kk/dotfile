{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dualboot;
in
{
  options.modules.dualboot = {
    enable = mkOption {
      description = "Enable Grub/DualBoot";
      type = types.bool;
      default = false;
    };
    windowsUUID = mkOption {
      description = "Select the Disk where windows is installed by UUID. You can find the UUID with lsblk -fa";
      type = types.str;
      default = "";
    };
  };

  config = {
    # Bootloader
    boot.loader = {
      timeout = 1;
      efi.canTouchEfiVariables = true;
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        gfxmodeEfi = "3840x2400";
        fontSize = 12;
        font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
        extraEntries = mkMerge [
          '' 
          menuentry "Reboot" {
           reboot
          }
          menuentry "Poweroff" {
           halt
          }
          menuentry "UEFI Firmware Settings" {
           fwsetup
          }
          ''
          (mkIf cfg.enable ''
            menuentry "Windows" {
             insmod part_gpt
             insmod fat
             search --no-floppy --fs-uuid --set=root  ${cfg.windowsUUID}   
             chainloader /efi/Microsoft/Boot/bootmgfw.efi
            }
          '')
        ];
      };
    };
  };
}
