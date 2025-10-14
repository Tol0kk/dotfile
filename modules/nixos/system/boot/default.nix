{
  pkgs,
  lib,
  config,
  assets,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.system.boot;
in
{
  options.modules.system.boot = {
    windowsUUID = mkOption {
      description = "Select the Disk where windows is installed by UUID. This Speed up the processed from Osprober. You can find the UUID with lsblk -fa";
      type = types.str;
      default = "";
    };
    systemd.enable = mkEnableOpt "Enable SystemD bootloader";
    limine.enable = mkEnableOpt "Enable Limine bootloader";
    grub = {
      enable = mkEnableOpt "Enable Grub bootloader";
      useOSProber = mkEnableOpt "Enable OSProber, append entries for other OSs detected by os-prober. This will scan entries every rebuild";
    };
    plymouth.enable = mkEnableOpt "Enable Plymouth";
  };

  config = mkMerge [
    {
      assertions = [
        {
          assertion = cfg.systemd.enable || cfg.grub.enable || cfg.limine.enable;
          message = ''
            You have to enable systemd or grub bootloader with one of the following:
              - modules.system.boot.systemd.enable
              - modules.system.boot.grub.enable
          '';
        }
        {
          assertion = cfg.systemd.enable || cfg.grub.enable || cfg.limine.enable;
          message = ''
            You have enable systemd and grub bootloader. You can only choose ONE of the following:
              - modules.system.boot.systemd.enable
              - modules.system.boot.grub.enable
          '';
        }
      ];
    }
    (mkIf cfg.grub.enable {
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
            # (mkIf (cfg.windowsUUID != "") ''
            #   menuentry "Windows" {
            #    insmod part_gpt
            #    insmod fat
            #    search --no-floppy --fs-uuid --set=root  ${cfg.windowsUUID}
            #    chainloader /efi/Microsoft/Boot/bootmgfw.efi
            #   }
            # '')
          ];
        };
      };
    })
    (mkIf cfg.systemd.enable {
      boot.kernelParams = [ "quiet" ];
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
    })
    (mkIf cfg.limine.enable {
      boot.loader.limine.enable = true;
      boot.loader.limine.secureBoot.enable = true;
      boot.loader.limine.style.wallpapers = [
        assets.backgrounds.background-1
      ];
    })
    (mkIf ((cfg.grub.enable || cfg.limine.enable) && cfg.plymouth.enable) {
      boot = {
        initrd.systemd.enable = true; # Needed for plymouth
        plymouth = {
          enable = true;
          theme = "nixos-plymouth-custom";
          # theme = "cubes";
          themePackages = with pkgs; [
            # By default we would install all themes
            (adi1090x-plymouth-themes.override {
              selected_themes = [ "cubes" ];
            })
            pkgs.nixos-plymouth-custom
          ];
        };

        # Enable "Silent Boot"
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "loglevel=3"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ];
      };
    })
  ];
}
