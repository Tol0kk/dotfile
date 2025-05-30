{
  lib,
  pkgs,
  self,
  config,
  ...
}: {
  modules = {
    kitty.enable = true;
    vscode.enable = true;
    git.enable = true;
    shell.enable = true;
    emacs.enable = true;
    hypr.enable = true;
    anyrun.enable = true;
    zathura.enable = true;
    mpv.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
  };

  # Look for matugen

  home.sessionVariables = {
    MY_BROWSER = "${pkgs.firefox}/bin/firefox"; # TODO: move to browser config file later
  };

  sops.defaultSopsFile = "${self}/secrets/secrets.yaml";
  sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  sops.defaultSopsFormat = "yaml";

  programs.nix-your-shell.enable = true;

  programs.zed-editor = {
    enable = true;
    extensions = ["nix" "toml" "elixir" "make"];
    userSettings = {
      hour_format = "hour24";
      auto_update = false;
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      show_whitespaces = "all";
      assistant = {
        enabled = true;
        version = "2";
        default_open_ai_model = null;
        default_model = {
          provider = "zed.dev";
          model = "claude-3-5-sonnet-latest";
        };
      };
      node = {
        path = lib.getExe pkgs.nodejs;
        npm_path = lib.getExe' pkgs.nodejs "npm";
      };
      lsp = {
        rust-analyzer = {
          binary = {
            path = "rust-analyzer";
          };
        };
        nix = {
          binary = {
            path_lookup = true;
          };
        };

        elixir-ls = {
          binary = {
            path_lookup = true;
          };
          settings = {
            dialyzerEnabled = true;
          };
        };
      };
    };
  };

  # Thunderbird
  programs.thunderbird = {
    enable = true;
    profiles."default" = {isDefault = true;};
  };

  home.packages = with pkgs; [
    grim
    slurp
    swappy
    wl-clipboard
    libnotify
    jq
    ags
    waybar
    gtksourceview
    accountsservice
    libdbusmenu-gtk3
    cargo-generate
    brave
    satty
    hyprshot
    ironbar
  ];

  services.amberol.enable = true;
}
