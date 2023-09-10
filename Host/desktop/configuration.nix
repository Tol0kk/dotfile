{ self, lib, config, pkgs, inputs, ... } @ inputss:
{
  # boot.kernelParams = lib.mkDefault [ "acpi_rev_override" ];
  # boot.initrd.kernelModules = [ "i915" ];
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nix.settings = {
    # Should not whant this for the server
    # for nix develop to keep derivation
    keep-outputs = true;
    keep-derivations = true;
  };

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-132b.psf.gz";

  # Bootloader
  boot.loader = {
    timeout = 5;
    efi.canTouchEfiVariables = true;
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      gfxmodeEfi = "3840x2400";
      fontSize = 12;
      font = "${pkgs.hack-font}/share/fonts/hack/Hack-Regular.ttf";
      extraEntries = '' 
      menuentry "Windows" {
       insmod part_gpt
       insmod fat
       search --no-floppy --fs-uuid --set=root 3EBE-7C56    
       chainloader /efi/Microsoft/Boot/bootmgfw.efi
      }
      menuentry "Reboot" {
       reboot
      }
      menuentry "Poweroff" {
       halt
      }
      menuentry "UEFI Firmware Settings" {
       fwsetup
      }
     '';
    };
  };

  services.fwupd.enable = true;

  services.udisks2.enable = true;
  services.gvfs.enable = true; # auto mount thunar

  boot.kernelPackages = pkgs.linuxPackages_6_4;

  programs.dconf.enable = true;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # extraPortals = [ inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland ];
  };

  # hardware.pulseaudio.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";




  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # hardware.steam-hardware.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  fileSystems."/Windows/Divers" = {
    device = "/dev/disk/by-uuid/0AC06BC1C06BB19D";
    fsType = "ntfs-3g";
    options = [ "rw" ];
  };

  fileSystems."/Windows/Données" = {
    device = "/dev/disk/by-uuid/64948C42948C18A6";
    fsType = "ntfs-3g";
    options = [ "rw" ];
  };

  programs.adb.enable = true;
  security.polkit.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

}
