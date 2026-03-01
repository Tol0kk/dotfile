{ inputs, ... }:
{
  flake.homeModules.theme =
    {
      pkgs,
      lib,
      config,
      assets,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    let
      cfg = config.modules.desktop.theme;
    in
    {
      imports = [ inputs.stylix-unstable.homeModules.stylix ];
      options.modules.desktop.theme = {
        theme = mkOption {
          description = "Set theme. List inside {pkgs.base16-schemes}/share/themes";
          type = types.nullOr types.str;
        };
        opacity = mkOption {
          description = "Set theme opacity";
          default = 0.8;
        };
        font-size = mkOption {
          description = "Set theme font_size";
          default = 11;
        };
        polarity = mkOption {
          description = "Theme polarity";
          type =
            with types;
            (enum [
              "dark"
              "light"
            ]);
          default = "light";
        };
        background-image = mkOption {
          description = "Set background. given a path.";
          type = types.path;
          # default = "onedark";
          default = assets.backgrounds.background-2; # TODO place ugly background
        };
      };
      config = {
        modules = {
          desktop = {
            theme = {
              opacity = mkDefault 0.92;
              polarity = mkDefault "dark";
              theme = mkDefault "gruvbox-dark-medium";
              background-image = mkDefault assets.backgrounds.takopi;
            };
          };
        };

        programs.home-manager.enable = true;
        # stylix.targets.wpaperd.enable = false;
        # services.wpaperd = {
        #   enable = true;
        #   settings = {
        #     default = {
        #       path = cfg.background-image;
        #     };
        #   };
        # };
        gtk.enable = true;
        gtk.iconTheme.package = pkgs.tela-icon-theme;
        gtk.iconTheme.name = "Tela-blue-dark";

        stylix.enable = true;
        stylix.image = cfg.background-image;
        stylix.polarity = "dark";

        stylix.base16Scheme = mkIf (
          cfg.theme != ""
        ) "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";

        stylix.opacity = {
          terminal = cfg.opacity;
          popups = cfg.opacity;
        };

        home.pointerCursor.gtk.enable = true;
        home.pointerCursor.hyprcursor.enable = true;
        home.pointerCursor.hyprcursor.size = 24;
        home.pointerCursor.x11.enable = true;
        home.pointerCursor.x11.defaultCursor = "phinger-cursors-light";

        stylix.cursor = {
          package = pkgs.phinger-cursors;
          name = "phinger-cursors-light";
          size = 24;
        };

        qt = {
          enable = true;
          platformTheme.name = mkForce "gtk3";
        };

        stylix.fonts = with pkgs; {
          serif = {
            package = noto-fonts-cjk-sans;
            name = "Noto Sans CJK JP";
          };

          sansSerif = {
            package = noto-fonts-cjk-sans;
            name = "Noto Sans CJK JP";
          };

          monospace = {
            package = maple-mono.NF-CN;
            name = "Maple Mono NF CN";
          };

          emoji = {
            package = noto-fonts-color-emoji;
            name = "Noto Color Emoji";
          };

          sizes = {
            applications = cfg.font-size;
            desktop = cfg.font-size;
            popups = cfg.font-size;
            terminal = cfg.font-size;
          };
        };
      };
    };

  flake.nixosModules.theme =
    {
      lib,
      libCustom,
      config,
      assets,
      inputs,
      pkgs,
      ...
    }:
    with lib;
    with libCustom;
    let
      cfg = config.modules.system.stylix;
    in
    {
      options.modules.system.stylix = {
        enable = mkEnableOpt "Enable Stylix";
      };

      imports = [ inputs.stylix.nixosModules.stylix ];
      config = mkMerge [
        (mkIf (!cfg.enable) { stylix.autoEnable = false; })
        (mkIf cfg.enable {
          # stylix.autoEnable = false;
          stylix.enable = true;
          stylix.polarity = "dark";
          stylix.image = assets.backgrounds.background-1;
          stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

          stylix.targets.plymouth.enable = false;

          stylix.cursor = {
            package = pkgs.phinger-cursors;
            name = "phinger-cursors-light";
            size = 24;
          };
          stylix.fonts = with pkgs; {
            serif = {
              package = noto-fonts-cjk-sans;
              name = "Noto Sans CJK JP";
            };

            sansSerif = {
              package = noto-fonts-cjk-sans;
              name = "Noto Sans CJK JP";
            };

            monospace = {
              package = maple-mono.truetype;
              name = "Maple Mono";
            };

            emoji = {
              package = noto-fonts-color-emoji;
              name = "Noto Color Emoji";
            };
          };
        })
      ];
    };
}
