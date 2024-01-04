{ pkgs, lib, config, self, ... }:

with lib;
let
  cfg = config.modules.grub;
in
{
  options.modules.grub = {
    windowsUUID = mkOption {
      description = "Select the Disk where windows is installed by UUID. This Speed up the processed from Osprober. You can find the UUID with lsblk -fa";
      type = types.str;
      default = "";
    };
    useOSProber = mkOption {
      description = "Enable OSProber, append entries for other OSs detected by os-prober. This will scan entries every rebuild";
      type = types.bool;
      default = false;
    };
  };

  config = {
    # Bootloader
    boot.loader = {
      timeout = 1;
      efi.canTouchEfiVariables = true;
      grub = {
        # theme = pkgs.sleek-grub-theme.override {
        #   withStyle = "dark";
        # };
        theme = "${(pkgs.callPackage "${self}/Pkgs/big-sur" {})}/theme.txt";
        useOSProber = cfg.useOSProber;
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
          (mkIf (cfg.windowsUUID != "") ''
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
