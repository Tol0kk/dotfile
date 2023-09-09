{ self, lib, config, pkgs, inputs, ... } @ inputss:
{
  environment.sessionVariables = {
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
    WLR_NO_HARDWARE_CURSORS = "1";
  };


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

   hardware.opengl = {
     enable = true;
     driSupport = true;
      driSupport32Bit = true;
     extraPackages = with pkgs; [
       vaapiVdpau
     ];
   };
  # boot.kernelParams = lib.mkDefault [ "acpi_rev_override" ];
  hardware.nvidia = {
     modesetting.enable = true;
     nvidiaSettings = true;
     package = config.boot.kernelPackages.nvidiaPackages.latest;
  #   # prime = {
  #   # offload.enable = true;
  #   # offload.enableOffloadCmd = true;
  #   # intelBusId = "PCI:0:2:0";
  #   # nvidiaBusId = "PCI:1:0:0";
  #   # };
  #   # powerManagement = {
  #   #   enable = true;
  #   #   # finegrained = true;
  #   # };
  };
  # services.xserver.videoDrivers = [ "nvidia" "modesetting" "fbdev" ];
  services.xserver.videoDrivers = [ "nvidia" ];

  programs.steam.enable = true;
  hardware.steam-hardware.enable = true;
  programs.steam.gamescopeSession.enable = true;

  nix.settings = {
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
     '';
    };
  };
  services.fwupd.enable = true;

  # NTFS Support
  boot.supportedFilesystems = [ "ntfs" ];
  services.udisks2.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_6_4;

  # services.xserver.enable = true;
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.displayManager.sddm.theme = "${../../Pkgs/sddm-chili}";

  programs.waybar.enable = true;
  programs.fish.enable = true;

  programs.nix-index.enable = true;
  programs.nix-index.enableFishIntegration = true;
  programs.nix-index.enableBashIntegration = true;
  programs.command-not-found.enable = false;

  services.gvfs.enable = true; # auto mount thunar

  services.udev.enable = true;
  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "openocd";
      text = ''
        # STM32F3DISCOVERY - ST-LINK/V2.1
        ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0666"
      '';
      destination = "/etc/udev/rules.d/99-openocd.rules";
    })
    (pkgs.writeTextFile {
      name = "arduino";
      text = ''
        # SATMEGA ARDUINO 3Dprinter
        ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0042", MODE:="0666"
      '';
      destination = "/etc/udev/rules.d/99-arduino-udev.rules";
    })

  ];
  programs.dconf.enable = true;


  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    extraPortals = [ inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland ];
  };
  security.sudo.wheelNeedsPassword = false;

  # BLUETOOTH

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };
  services.blueman.enable = true;
  hardware.pulseaudio = {
    package = pkgs.pulseaudioFull;
  };
  # hardware.pulseaudio.enable = true;

  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "fr";
    xkbVariant = "";
  };

  # Configure console keymap
  console.keyMap = "fr";

  users.users.titouan = {
    isNormalUser = true;
    description = "titouan";
    shell = pkgs.fish;
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "docker" "adbusers" "dialout"];
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    neovim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    helix
    wget
    git
    kitty
    rofi-wayland
    brave
    vscodium
    libsForQt5.qt5.qtgraphicaleffects # sddm
    xfce.tumbler
    xfce.thunar
    xfce.thunar-dropbox-plugin
    xfce.thunar-media-tags-plugin
    xfce.thunar-archive-plugin
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
    (callPackage "${self}/Pkgs/sddm-chili" { username = "titouan"; }) # for sddm
  ];
  security.polkit.enable = true;

  # hardware.steam-hardware.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
  security.pam.enableSSHAgentAuth = true;
  security.pam.services.sudo.sshAgentAuth = true;
  services.openssh.settings.PasswordAuthentication = false;
  programs.ssh.startAgent = true;


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
}
