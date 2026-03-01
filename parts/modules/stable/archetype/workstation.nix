{ self, ... }:
{
  flake.nixosModules.workstation =
    {
      inputs,
      pkgs,
      lib,
      ...
    }:
    {
      # Essentials
      imports = [
        self.nixosModules.networks
        self.nixosModules.sops
        self.nixosModules.ssh
      ];

      programs.dconf.enable = true;

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

        # Good to have
        lazygit
        nix-du
        iperf # network benchmark

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

        # Basic LSP
        nil
        nixd
        typst
        tinymist
      ];
    }
    // {
      # NTFS
      environment.systemPackages = with pkgs; [
        ntfs3g
      ];
      boot.supportedFilesystems = [ "ntfs" ];
    }
    // {
      # Flatpak
      imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
      services.flatpak.enable = true;
    }
    // {
      # Nix registries
      nix.registry.nixpkgs.flake = inputs.nixpkgs-unstable;
      nix.nixPath = [ "nixpkgs=${inputs.nixpkgs-unstable}" ];
    }
    // {
      # Graphics
      hardware.graphics = {
        enable = true;
        enable32Bit = true;
      };
    }
    // {
      # Network
      networking.networkmanager.enable = true;
      imports = [ self.nixosModules.networks ];
    }
    // {
      # agents
      programs.gnupg.agent = {
        enable = true;
        pinentryPackage = pkgs.pinentry-tty;
        # enableSSHSupport = true;
      };
    }
    // {
      # File Manager
      services.udisks2.enable = true;
      services.gvfs.enable = true;
    }
    // {
      # Nix Index
      programs.nix-index.enable = true;
      programs.nix-index.enableZshIntegration = true;
      programs.nix-index.enableFishIntegration = true;
      programs.nix-index.enableBashIntegration = true;
      programs.command-not-found.enable = false;
    }
    // {
      # DirEnv
      programs.direnv.enable = true;
      programs.direnv.silent = true;
      programs.direnv.nix-direnv.enable = true;
    }
    // {
      # GMK keybord
      hardware.keyboard.qmk.enable = true;
      services.udev.packages = [ pkgs.via ];
    }
    // {
      # Security
      security.apparmor = {
        enable = true;
        packages = [ pkgs.apparmor-profiles ];
      };

      # DNS
      services.dnscrypt-proxy2 = {
        enable = true;
        settings = {
          ipv6_servers = true;
          require_dnssec = true;
          server_names = [ "cloudflare" ]; # Only use Cloudflare
        };
      };
      networking.nameservers = [
        "127.0.0.1"
        "::1"
      ];

      services.fwupd.enable = true; # Firware Update
    }
    // {
      # Nix LD
      programs.nix-ld.enable = true;
      programs.nix-ld.libraries = with pkgs; [
        stdenv.cc.cc
        libusb1
        zlib
        fuse3
        icu
        ncurses
        libdecor.out
        openssl.dev
        openssl
        nss
        openssl
        curl
        expat
        # ...
      ];
    }
    // {
      # Performance
      services.tuned.enable = true;
      services.tlp.enable = false;
      services.upower.enable = true;

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
    }
    // {
      # Audio
      services.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };
    };
}
