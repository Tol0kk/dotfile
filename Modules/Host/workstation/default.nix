{ pkgs, self, inputs, lib, config, pkgs-stable, pkgs-unstable, ... }:


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
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];
  config = mkMerge [
    (import ./gnome { inherit pkgs self inputs lib config pkgs-stable; })
    (import ./hypr { inherit pkgs self inputs lib config pkgs-stable; })
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
        { appId = "io.github.zen_browser.zen"; origin = "flathub"; }
      ];


      # desktop
      programs.firefox.enable = true;
      networking.networkmanager.enable = true;
      services.udisks2.enable = true;
      services.printing.enable = true;
      programs.dconf.enable = true;


      ## audio
      hardware.pulseaudio.enable = false;
      security.rtkit.enable = true;
      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
      };

      programs.ssh.startAgent = true;


      programs.nix-index.enable = true;
      programs.nix-index.enableZshIntegration = true;
      programs.nix-index.enableFishIntegration = true;
      programs.nix-index.enableBashIntegration = true;
      programs.command-not-found.enable = false;
      programs.direnv.enable = true;
      programs.direnv.silent = true;
      programs.direnv.nix-direnv.enable = true;

      

      ## package
      environment.systemPackages = with pkgs; [
          busybox
        openssl
        openfortivpn # University VPN
        ani-cli
        pkgs.diffsitter.out
        onlyoffice-bin
        # blender_4_0
        xarchiver
        vulkan-tools
        obsidian
        iperf # network benchmark
        onagre
        zoxide
        yazi
        tldr
        file
        btop
        jq
        imv
        unzip
        vlc
        discord
        qbittorrent
        gnome-multi-writer
        vdhcoapp # for Video DownloadHelper Firefox extension
        colmena # Nixos Deploy Framework
        pavucontrol # Audio Control Panel
        oculante # Image Viewer / editor
   
        # Typst 
        typst-lsp
        typst
        tinymist
      ];
    })
  ];
}
