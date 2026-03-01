# Imported
{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.system.desktopEnvironment.gnome;
in
{
  options.modules.system.desktopEnvironment.gnome = {
    enable = mkEnableOpt "Enable Gnome Desktop Environment";
  };

  config = mkIf cfg.enable {
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-tweaks
    ];

    # Desactivate voice synthesis
    services.orca.enable = false;
    services.speechd.enable = false;

    environment.gnome.excludePackages = with pkgs; [
      gnome-photos # Alternative: ocultante
      gnome-tour # Useless
      gnome-user-docs
      pkgs.gedit # text editor, Alternative nvim / vscode
      gnome-terminal # Alternative: kitty
      epiphany # web browser, Alternative Firefox / brave
      geary # email reader, Alternative Thunderbird
      evince # document viewer, Alternative Zathura
      totem # video player, Alternative  MPV
      gnome-contacts # Useless
      gnome-maps # Useless
      gnome-weather # Useless
      gnome-music # Alternative: amberol
      tali # poker game, Useless
      iagno # go game, Useless
      hitori # sudoku game, Useless
      atomix # puzzle game, Useless
      gnome-text-editor # Useless
      # ]) ++ (with pkgs.gnome; [
      # cheese # webcam tool, No current alternative
    ];
  };
}
