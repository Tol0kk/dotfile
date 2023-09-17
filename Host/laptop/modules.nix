{ self, lib, config, pkgs, inputs, ... } @ inputss:
{
  config.modules = {
    fonts.enable = true;
    nvidia.enable = true;
    virtualisation.enable = true;
    virtualisation.virtualbox.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.waydroid.enable = false;
    thunar.enable = true;
    gaming.enable = true;
    bluetooth.enable = true;
    jellyfin.enable = false;
    udev.STM32DISCOVERY.enable = true;
    udev.ArduinoMega.enable = true;
    dualboot = {
      enable = true;
      windowsUUID = "3EBE-7C56";
    };
    general.sessionVariables = {
      XCURSOR_SIZE = "128";
      XCURSOR_PATH = [
        "${config.system.path}/share/icons"
        "$HOME/.icons"
        "$HOME/.nix-profile/share/icons/"
      ];
      GTK_DATA_PREFIX = [
        "${config.system.path}"
      ];
      NIXOS_DOTFILE_DIR = "${self}";
    };
    general.systemPackages = with pkgs; [
      helix
      wget
      git
      kitty
      rofi-wayland
      brave
      vscodium
      libsForQt5.qt5.qtgraphicaleffects # sddm

      zip
      wpaperd
      ripgrep
      swaynotificationcenter

      pavucontrol

      btop

      lshw
      glxinfo

      direnv
      nixpkgs-fmt
      home-manager

      gpu-viewer
      nvitop
      unigine-valley
      unigine-heaven

      imagemagick # utils
      vulkan-tools # utils-gpu
      (callPackage "${self}/Pkgs/nixer" { })
    ];
  };
}
