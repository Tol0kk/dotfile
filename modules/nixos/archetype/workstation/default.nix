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
          desktopEnvironment.niri = enabled;
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

      assertions = [
        {
          assertion =
            config.modules.system.desktopEnvironment.gnome.enable
            || config.modules.system.desktopEnvironment.niri.enable
            || config.modules.system.desktopEnvironment.hypr.enable;
          message = ''
            You have to enable at leat one desktop environment.
          '';
        }
      ];

      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-tty;
        # enableSSHSupport = true;
      };

      networking.networkmanager.enable = true;

      # Flatpack
      services.flatpak.enable = true;

      services.udisks2.enable = true;
      programs.dconf.enable = true;
      # programs.ssh.startAgent = true;

      programs.nix-index.enable = true;
      programs.nix-index.enableZshIntegration = true;
      programs.nix-index.enableFishIntegration = true;
      programs.nix-index.enableBashIntegration = true;
      programs.command-not-found.enable = false;

      programs.direnv.enable = true;
      programs.direnv.silent = true;
      programs.direnv.nix-direnv.enable = true;

      services.gvfs.enable = true;

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

      # Enforce DNS over HTTPS
      services.dnscrypt-proxy2 = {
        enable = true;
        settings = {
          ipv6_servers = true;
          require_dnssec = true;
          server_names = [ "cloudflare" ]; # Only use Cloudflare
        };
      };

      # Force all system DNS to look at the local dnscrypt proxy
      networking.nameservers = [
        "127.0.0.1"
        "::1"
      ];
      networking.networkmanager.dns = "none";

      ## package
      environment.systemPackages = with pkgs; [
        # Essentials
        zip
        p7zip
        graphviz
        ani-cli
        yazi
        tldr
        file
        btop
        jq
        imv
        unzip
        ffmpeg.bin
        colmena # Nixos Deploy Framework
        vulkan-tools
        busybox
        openssl
        imagemagick
        xdg-utils
        wireguard-tools
        feh
        qrencode
        home-manager
        tparted

        # oculante # Image Viewer / editor

        # Heavy
        onlyoffice-desktopeditors
        inputs.zen-browser.packages."${system}".beta
        # obsidian
        # blender_4_0
        # android-studio
        # jetbrains.webstorm
        # sphinx # Python documentation generator (used for linux kernel documentation generation)
        unoconv # Convertion tool .ppt(x) to .pdf (any document from and to any LibreOffice supported format)
        # qbittorrent
        # gparted

        payloadsallthethings
        lazygit
        nix-du
        iperf # network benchmark
        # joplin # Note taking app
        # vial # QMK/Via for Keyboard
        # via # QMK/Via for Keyboard

        # TODO move:
        pwvucontrol # Audio Control Panel
        gpu-viewer # Front-end to glxinfo, vulkaninfo, clinfo and es2_info
        onagre

        # LSP
        nil
        nixd

        # Typst
        typst
        tinymist

        # flex ??

      ];
    })
  ];
}
