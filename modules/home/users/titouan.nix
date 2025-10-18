{
  lib,
  libCustom,
  config,
  pkgs,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.users.titouan;
in
{
  options.modules.users.titouan = {
    enable = mkEnableOpt "Enable Titouan Users";
  };

  config = mkMerge [
    (mkIf cfg.enable {
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
    })
  ];
}
