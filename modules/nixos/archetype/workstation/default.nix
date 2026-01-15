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
      nix.registry.nixpkgs.flake = inputs.nixpkgs-unstable;

      # Also set the NIX_PATH for legacy commands
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];

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
        apps.thunar.enable = true;
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
      nix.optimise.automatic = true;
      nix.optimise.dates = [ "03:45" ];

      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 7d";
      };

      # services.displayManager.ly.enable = true;
      programs.wireshark.enable = true;

      networking.networkmanager.enable = true;

      # Flatpack
      services.flatpak.enable = true;

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
        memoryPercent = lib.mkDefault 80;
        priority = 100;
      };

      services.ananicy = {
        enable = true;
        extraTypes = [
          {
            nice = -10;
            type = "ui";
          }
          {
            nice = -2;
            type = "terminal";
          }
          {
            nice = -1;
            type = "apps";
          }
          {
            nice = 3;
            type = "compiler";
          }
        ];
        extraRules = [
          {
            name = ".Hyprland-wrapp";
            type = "ui";
          }
          {
            name = "alacritty";
            type = "terminal";
          }
          {
            name = ".zed-editor-wra";
            type = "apps";
          }
          {
            name = "cargo";
            type = "compiler";
          }
          {
            name = "nix";
            type = "compiler";
          }
          {
            name = "nix-daemon";
            type = "compiler";
          }

        ];
      };

      qt.enable = true; # Used for quickshell developement

      services.tuned.enable = true;
      services.tlp.enable = false;
      services.upower.enable = true;
      programs.nix-ld.enable = true;

      # Sets up all the libraries to load
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
      ];

      ## package
      environment.systemPackages = with pkgs; [
        gpu-viewer # Front-end to glxinfo, vulkaninfo, clinfo and es2_info
        inputs.zen-browser.packages."${system}".beta
        caido
        seclists
        payloadsallthethings
        mullvad-browser
        lazygit
        nix-du
        graphviz
        p7zip
        zip
        joplin
        vial # QMK/Via for Keyboard
        via # QMK/Via for Keyboard
        mdcat
        # onlyoffice-bin
        # obsidian
        pwvucontrol # Audio Control Panel
        ani-cli
        yazi
        onagre
        blender_4_0
        iperf # network benchmark
        mdcat
        # android-studio
        tldr
        file
        # jetbrains.webstorm
        btop
        jq
        imv
        unzip
        # vlc
        # discord
        ffmpeg.bin
        # qbittorrent
        # gnome-multi-writer
        vdhcoapp # for Video DownloadHelper Firefox extension
        colmena # Nixos Deploy Framework
        vulkan-tools
        busybox
        nil
        nixd
        openssl
        # openfortivpn # University VPN
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

        sphinx # Python documentation generator (used for linux kernel documentation generation)

        flex
        imagemagick
        feh

        gparted
        tparted

        home-manager
        qbittorrent

      ];
    })
  ];
}
