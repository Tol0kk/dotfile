{ pkgs, self, inputs, lib, config }:

with lib;
let
  cfg = config.modules.workstation.gnome;
in
mkIf cfg.enable {
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  environment.systemPackages = with pkgs; [
    gnome.gnome-tweaks
  ];

  environment.gnome.excludePackages = (with pkgs; [
    gnome-photos # Alternative: ocultante
    gnome-tour # Useless
    gnome-user-docs
    pkgs.gedit # text editor, Alternative nvim / vscode
  ]) ++ (with pkgs.gnome; [
    pkgs.gnome-text-editor # Useless
    gnome-contacts # Useless
    gnome-maps # Useless
    gnome-weather # Useless
    # cheese # webcam tool, No current alternative 

    gnome-music # Alternative: amberol
    gnome-terminal # Alternative: kitty
    epiphany # web browser, Alternative Firefox / brave
    geary # email reader, Alternative Thunderbird
    evince # document viewer, Alternative Zathura
    totem # video player, Alternative  MPV
    tali # poker game, Useless
    iagno # go game, Useless
    hitori # sudoku game, Useless
    atomix # puzzle game, Useless
  ]);
}
