{ pkgs, lib, config, inputs, username, ... }:
with lib;
let cfg = config.modules.firefox;

in {
  options.modules.firefox = {
    enable = mkOption {
      description = "Enable firefox";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      profiles.${username} = {

        settings = {
          "toolkit.legacyUserProfileCustomizations.stylesheets" = false;
          "svg.context-properties.content.enabled" = true;
        };

        extensions = with inputs.firefox-addons.packages."x86_64-linux"; [
          ublock-origin
          sponsorblock
          darkreader
          tridactyl
          youtube-shorts-block
        ];

        bookmarks = [
          {
            name = "youtube";
            url = "https://www.youtube.com/";
          }
          {
            name = "Nix sites";
            toolbar = true;
            bookmarks = [
              {
                name = "homepage";
                url = "https://nixos.org/";
              }
              {
                name = "wiki";
                tags = [ "wiki" "nix" ];
                url = "https://nixos.wiki/";
              }
              {
                name = "home-manager";
                url = "https://nix-community.github.io/home-manager/options.html";
              }
            ];
          }
        ];
      };
    };
  };
}
