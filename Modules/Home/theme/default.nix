{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.theme;
in {
  imports = [inputs.stylix.homeManagerModules.stylix];
  options.modules.theme = {
    theme = mkOption {
      description = "Set theme. List inside {pkgs.base16-schemes}/share/themes";
      type = types.str;
      # default = "onedark";
      default = "gruvbox-dark-medium";
    };
    opacity = mkOption {
      description = "Set theme opacity";
      default = 0.8;
    };
    font-size = mkOption {
      description = "Set theme font_size";
      default = 11;
    };
    background-image = mkOption {
      description = "Set background. given a path.";
      type = types.str;
      # default = "onedark";
      default = "${pkgs.assets}/background-1.jpg";
    };
  };
  config = {
    services.wpaperd = {
      enable = true;
      settings = {
        default = {
          path = cfg.background-image;
        };
      };
    };
    gtk.enable = true;
    gtk.iconTheme.package = pkgs.colloid-icon-theme;
    gtk.iconTheme.name = "Colloid-dark";

    stylix.enable = true;
    stylix.image = cfg.background-image;
    stylix.polarity = "dark";

    stylix.base16Scheme =
      mkIf
      (
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
        # Full version, embed with icons, Chinese and Japanese glyphs (With -NF-CN suffix)
        # Unhinted font is used for high resolution screen (e.g. for MacBook). Using "hinted font" will blur your text or make it looks weird. 
        package = maple-mono.truetype;
        name = "Maple Mono";
      };

      emoji = {
        package = noto-fonts-emoji;
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
}
