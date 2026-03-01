{
  flake.nixosModules.grub =
    { pkgs, lib, ... }:
    {
      boot.kernelParams = [ "quiet" ];
      boot.loader = {
        timeout = 1;
        efi.canTouchEfiVariables = true;
        grub = {
          theme = lib.mkDefault (
            pkgs.sleek-grub-theme.override {
              withStyle = "dark";
            }
          );
          # theme = pkgs.sleek-grub-theme;
          # useOSProber = cfg.useOSProber;
          enable = true;
          device = "nodev";
          efiSupport = true;
          # gfxmodeEfi = "1920x1080";
          gfxmodeEfi = "3840x2400";
          # fontSize = 30;
          # font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
          extraEntries = lib.mkMerge [
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
            # ''
            #   menuentry "Windows" {
            #    insmod part_gpt
            #    insmod fat
            #    search --no-floppy --fs-uuid --set=root  ${cfg.windowsUUID}
            #    chainloader /efi/Microsoft/Boot/bootmgfw.efi
            #   }
            # ''
          ];
        };
      };
    };
}
