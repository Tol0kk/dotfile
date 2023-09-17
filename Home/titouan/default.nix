{ pkgs, config, username, self, ... }:
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
    firefox.enable = true;
    gaming.enable = true;
    git.enable = true;
    gpg.enable = true;
    kitty.enable = true;
    alacritty.enable = true;
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

    general = {
      packages = with pkgs; [
        foliate
        zathura
        imv
        mpv
        ffmpeg
        unzip
        pfetch
        bat
        yt-dlp
        onlyoffice-bin
        discord
        # ani-cli
        fzf
        aria
        sops # For Sops-nix. has a home-manager module
      ];
      sessionVariables = {
        XCURSOR_SIZE = "128";
        XCURSOR_PATH = "$HOME/.icons:$HOME/.nix-profile/share/icons/";
        NIXOS_DOTFILE_DIR = "${self}";
      };
      sessionPath = [
        "$HOME/.cargo/bin"
      ];
    };
  };


}
