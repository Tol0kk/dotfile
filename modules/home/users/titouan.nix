{
  lib,
  libCustom,
  config,
  pkgs,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.users.titouan;
in {
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
            vencord = enabled;
            yazi = enabled;
            mpv = enabled;
            zathura = enabled;
            thunderbird = enabled;
          };
        };

        services = {
          element.enable = lib.mkDefault true;
          signal.enable = lib.mkDefault true;
        };

        shell = {
          bash = enabled;
          fish = enabled;
          starship = enabled;
          zellij.enable = lib.mkDefault false;
          zoxide = enabled;
        };

        desktop = {
          wayland.onagre.enable = false; # Slow asf
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
