{
  pkgs,
  self,
  inputs,
  lib,
  config,
  pkgs-stable,
  ...
}:
with lib; let
  cfg = config.modules.workstation;
in {
  options.modules.workstation = {
    enable = mkOption {
      description = "Enable workstation modules";
      type = types.bool;
      default = false;
    };
    gnome.enable = mkOption {
      description = "Enable Gnome system wide";
      type = types.bool;
      default = false;
    };
    hypr.enable = mkOption {
      description = "Enable Hyprland system wide. The configuration of hyprland is set by HomeManager";
      type = types.bool;
      default = false;
    };
  };

  # imports =
  #   if cfg.enable then [
  #     # ./gnome/default.nix
  #     # ./hypr/default.nix
  #   ] else [ ];
  imports = [inputs.nix-flatpak.nixosModules.nix-flatpak];
  config = mkMerge [
    (import ./gnome {inherit pkgs self inputs lib config pkgs-stable;})
    (import ./hypr {inherit pkgs self inputs lib config pkgs-stable;})
    (mkIf cfg.enable {
      programs.wireshark.enable = true;
      # University VPN Config need openfortivpn package
      sops.secrets."titouan/univ_vpn_file" = {
        # owner = "titouan";
        path = "/etc/open‐fortivpn/config";
      };

      # Flatpack
      services.flatpak.enable = true;
      services.flatpak.packages = [
      ];

      # desktop
      # programs.firefox.enable = true;
      services.udisks2.enable = true;
      programs.dconf.enable = true;

      # Kanidm Client
      services.kanidm = {
        enableClient = true;
        package = pkgs.kanidm;
        clientSettings = {
          uri = "https://sso.tolok.org";
        };
      };
      ## audio
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      # misc
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
      services.ollama = {
        enable = true;
        package = pkgs.ollama-cuda;
      };

      # keyboard
      hardware.keyboard.qmk.enable = true;
      services.udev.packages = [pkgs.via];

      # Desactivate voice synthesis
      services.orca.enable = false;
      services.speechd.enable = false;

      security.apparmor = {
        enable = true;
        packages = [pkgs.apparmor-profiles];
      };

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
        bitwarden-cli
        vlc
        discord
        qbittorrent
        gnome-multi-writer
        vdhcoapp # for Video DownloadHelper Firefox extension
        colmena # Nixos Deploy Framework
        vulkan-tools
        busybox
        nil
        openssl
        openfortivpn # University VPN
        xarchiver
        oculante # Image Viewer / editor
        wireguard-tools
        networkmanagerapplet
        qrencode

        # Typst
        typst
        tinymist
      ];
    })
  ];
}
