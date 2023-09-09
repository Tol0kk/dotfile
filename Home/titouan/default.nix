{ pkgs, config, username, ... }:
{
  config.modules = {
    anyrun.enable = true;
    avizo.enable = true;
    ags.enable = true;
    dev = {
      enable = true;
      languages = {
        nix.enable = true;
        octave.enable = false;
        R.enable = false;
        rust.enable = true;
        android.enable = true;
      };
    };
    direnv.enable = true;
    dunst.enable = false;
    swaync.enable = true;
    emacs.enable = true;
    eww.enable = true;
    gaming.enable = true;
    git.enable = true;
    gpg.enable = true;
    kitty.enable = true;
    lsd.enable = true;
    nix-index.enable = true;
    shells = {
      enable = true;
      zsh.enable = true;
      fish.enable = true;
      bash.enable = true;
      nushell.enable = true;
      startship.enable = true;
    };
    wayland = {
      enable = true;
      hyprland.enable = true;
      sway.enable = true;
      newm.enable = false;
    };
    wpaperd.enable = true;
    xdg.enable = true;
    zoxide.enable = true;
  };


}
