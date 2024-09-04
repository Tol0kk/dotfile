{ pkgs, self, inputs, lib, config, pkgs-stable,... }:


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

  config = mkMerge [
    (import ./gnome {inherit pkgs self inputs lib config pkgs-stable;})
    (import ./hypr {inherit pkgs self inputs lib config pkgs-stable;})
    (mkIf cfg.enable {
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
        qbittorrent
        gnome-multi-writer
        typst-lsp
        typst
        tinymist
	      vdhcoapp # for Video DownloadHelper Firefox extension

        oculante # Image Viewer / editor
      ];
    })
  ];
}
