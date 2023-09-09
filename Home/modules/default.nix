{ self, inputs, pkgs, config, ... }:

{
  imports = [
    # gui
    # ./foot
    # ./eww
    # ./dunst
    # ./hyprland
    # ./wofi

    # cli
    # ./nvim
    ./anyrun
    ./avizo
    ./ags
    ./dev
    ./direnv
    ./dunst
    ./emacs
    ./eww
    ./gaming
    ./git
    ./gpg
    ./kitty
    ./lsd
    ./nix-index
    ./shells
    ./swaync
    ./theme
    ./wayland
    ./wpaperd
    ./xdg
    ./zoxide
    # ./direnv

    # system
    # ./xdg
    # ./packages
  ];
  home.sessionVariables = {
    XCURSOR_SIZE = "128";
    XCURSOR_PATH = "$HOME/.icons:$HOME/.nix-profile/share/icons/";
    NIXOS_DOTFILE_DIR = "${self}";
  };
  home.packages = with pkgs; [
    foliate
    zathura
    imv
    tldr
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

  home.sessionPath = [
    "$HOME/.cargo/bin"
  ];

  nix.registry = {
    MyTemplate = {
      from = {
        id = "MyTemplate";
        type = "indirect";
      };
      to = {
        path = "${self}";
        type = "path";
      };
    };
  };


}
