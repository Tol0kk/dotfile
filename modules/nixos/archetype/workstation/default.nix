{
  pkgs,
  inputs,
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.archetype.workstation;
in
{
  options.modules.archetype.workstation = {
    enable = mkEnableOpt "Enable workstation archetype";
  };

  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  config = mkMerge [
    (mkIf cfg.enable {
      nix.registry.nixpkgs.flake = inputs.nixpkgs;

      # Also set the NIX_PATH for legacy commands
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

      modules = {
        hardware = {
          audio = enabled;
          filesystems.ntfs = enabled;
        };
        system = {
          fonts = enabled;
          desktopEnvironment.hypr = enabled;
          virtualisation.docker = enabled;
          virtualisation.qemu = enabled;
        };
        apps.neovim.enable = true;
        apps.neovim.custom.enable = true;
        apps.neovim.custom.minimal = false;
      };

      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };

      # Kanidm Client for my SSO # TODO make home manager module for this. ...it's a client. shouln't be systemd wide.
      services.kanidm = {
        enableClient = true;
        package = pkgs.kanidm;
        clientSettings = {
          uri = "https://sso.tolok.org";
        };
      };

      assertions = [
        {
          assertion =
            config.modules.system.desktopEnvironment.gnome.enable
            || config.modules.system.desktopEnvironment.hypr.enable;
          message = ''
            You have to enable at leat one desktop environment.
          '';
        }
      ];

      services.displayManager.ly.enable = true;
      programs.wireshark.enable = true;

      # Flatpack
      # services.flatpak.enable = true;

      services.udisks2.enable = true;
      programs.dconf.enable = true;
      programs.ssh.startAgent = true;

      programs.nix-index.enable = true;
      programs.nix-index.enableZshIntegration = true;
      programs.nix-index.enableFishIntegration = true;
      programs.nix-index.enableBashIntegration = true;
      programs.command-not-found.enable = false;

      programs.direnv.enable = true;
      programs.direnv.silent = true;
      programs.direnv.nix-direnv.enable = true;

      services.gvfs.enable = true;
      programs.adb.enable = true;

      # Add support for QMK keyboard
      hardware.keyboard.qmk.enable = true;
      services.udev.packages = [ pkgs.via ];

      security.apparmor = {
        enable = true;
        packages = [ pkgs.apparmor-profiles ];
      };

      services.fwupd.enable = true;

      # Activate Zram (Memory compression)
      zramSwap = {
        enable = true;
        algorithm = lib.mkDefault "zstd";
        memoryPercent = 80;
      };

      qt.enable = true; # Used for quickshell developement

      ## package
      environment.systemPackages = with pkgs; [
        inputs.zen-browser.packages."${system}".beta
        lazygit
        nix-du
        graphviz
        p7zip
        zip
        vial # QMK/Via for Keyboard
        via # QMK/Via for Keyboard
        mdcat
        onlyoffice-bin
        obsidian
        pavucontrol # Audio Control Panel
        ani-cli
        yazi
        onagre
        pkgs.diffsitter.out
        blender_4_0
        iperf # network benchmark
        mdcat
        android-studio
        tldr
        file
        jetbrains.webstorm
        btop
        jq
        imv
        unzip
        vlc
        discord
        ffmpeg.bin
        qbittorrent
        gnome-multi-writer
        vdhcoapp # for Video DownloadHelper Firefox extension
        colmena # Nixos Deploy Framework
        vulkan-tools
        busybox
        nil
        nixd
        openssl
        openfortivpn # University VPN
        xarchiver
        oculante # Image Viewer / editor
        wireguard-tools
        qrencode
        networkmanagerapplet
        imagemagick

        # LSP
        nil

        # Typst
        typst
        tinymist

        # QML developments (QT/quickshell)
        kdePackages.full

        sphinx # Python documentation generator (used for linux kernel documentation generation)

        flex
      ];
    })
  ];
}
