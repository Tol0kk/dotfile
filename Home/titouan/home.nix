{ self, lib, pkgs, config, ... }:
{
  modules = {
    kitty.enable = true;
    vscode.enable = true;
    git.enable = true;
    shell.enable = true;
    emails.enable = true;
    emacs.enable = true;
    hypr.enable = true;
    anyrun.enable = true;
    zathura.enable = true;
    mpv.enable = true;
    yazi.enable = true;
    zoxide.enable = true;
  };

  home.sessionVariables = {
    MY_BROWSER = "${pkgs.firefox}/bin/firefox"; # TODO: move to browser config file later
  };

  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" "elixir" "make" ];
    userSettings = {
      hour_format = "hour24";
      auto_update = false;
      load_direnv = "shell_hook";
      base_keymap = "VSCode";
      theme = {
        mode = "system";
        light = "One Light";
        dark = "One Dark";
      };
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


  home.packages = with pkgs;[
    grim
    slurp
    swappy
    wl-clipboard
    nil
    swaynotificationcenter
    libnotify
    jq
    ags
    waybar
    discord-canary
    gtksourceview
    webkitgtk
    accountsservice
    libdbusmenu-gtk3
  ];

  services.amberol.enable = true;
}
