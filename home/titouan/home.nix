{
  pkgs,
  self,
  config,
  libCustom,
  ...
}:
with libCustom; {
  modules = {
    apps = {
      editor.vscode = enabled;
      editor.zed = enabled;
      term.kitty = enabled;
      # term.alacritty = enabled;
      # term.wezterm = enabled;
      misc = {
        git = enabled;
        thunar = enabled;
        glxgears = enabled;
        mangohud = enabled;
        yazi = enabled;
        zathura = enabled;
        thunderbird = enabled;
      };
    };

    services = {
      element = enabled;
      syncthing = enabled;
      signal = enabled;
    };

    shell = {
      bash = enabled;
      fish = enabled;
      starship = enabled;
      zellij = disabled;
      zoxide = enabled;
    };

    desktop = {
      profiles = "aestetic";
      theme = {
        polarity = "dark";
      };
    };
  };

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.defaultSopsFormat = "yaml";

  home.packages = with pkgs; [
    # TODO move wayland
    grim
    slurp
    swappy
    wl-clipboard
    libnotify
    jq
    ags
    waybar
    gtksourceview
    libdbusmenu-gtk3
    satty
    hyprshot
    ironbar

    # personal
    accountsservice
    cargo-generate
    brave
  ];

  services.amberol.enable = true;
}
