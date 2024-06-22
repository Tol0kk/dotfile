{ pkgs, self, inputs, lib, config, ... }:


with lib;
let
  cfg = config.modules.workstation;
in
{
  options.modules.workstation = {
    enable = mkOption {
      description = "Enable workstation modules";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # gnome
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    # hyprland 
    # Enable touchpad support (enabled default in most desktopManager).
    # services.xserver.libinput.enable = true;
    # programs.hyprland.enable = true;
    # programs.waybar.enable = true;

    # desktop
    programs.firefox.enable = true;
    networking.networkmanager.enable = true;
    services.udisks2.enable = true;
    services.flatpak.enable = true;
    services.printing.enable = true;

    ## audio
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    # sound.enable = true;
    # sound.mediaKeys.enable = true;

    ## package
    environment.systemPackages = with pkgs; [
      ani-cli
      onlyoffice-bin
      blender_4_0
      xarchiver
      vulkan-tools
      iperf # network benchmark
      onagre
      file
      btop
      imv
      unzip
      vlc

      # hyprland
      # wl-clipboard

      # gnome 
      gnome.gnome-tweaks

    ];

  };
}
