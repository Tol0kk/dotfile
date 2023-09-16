{ self, lib, config, pkgs, inputs, ... } @ inputss:
{
  sound.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  nix.settings = {
    # for nix develop to keep derivation
    keep-outputs = true;
    keep-derivations = true;
  };

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-132b.psf.gz";

  services.fwupd.enable = true;

  services.udisks2.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_6_4;

  services.gvfs.enable = true; # auto mount thunar

  services.upower.enable = true;
  programs.dconf.enable = true;

  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    # extraPortals = [ inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland ];
  };

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  security.polkit.enable = true;

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

  fileSystems."/Windows" = {
    device = "/dev/disk/by-uuid/1C86D5F686D5D07E";
    fsType = "ntfs-3g";
    options = [ "rw" ];
  };

  programs.adb.enable = true;
}
