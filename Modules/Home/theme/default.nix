{ pkgs
, lib
, config
, ...
}:

with lib;
let
  cfg = config.modules.theme;
in
{
    
  import = [inputs.stylix.homeManagerModules.stylix];
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
  };
  config = {
    programs.wpaperd = {
      enable = true;
      settings = {
        default = {
          path = "${pkgs.assets}/background.jpg";
        };
      };
    };
    gtk.enable = true;
    gtk.iconTheme.package = pkgs.colloid-icon-theme;
    gtk.iconTheme.name = "Colloid-dark";


    stylix.enable = true;
    stylix.image = "${pkgs.assets}/background.jpg";
    stylix.polarity = "dark";

    stylix.base16Scheme = mkIf
      (
        cfg.theme != ""
      ) "${pkgs.base16-schemes}/share/themes/${cfg.theme}.yaml";

    stylix.opacity = {
      terminal = cfg.opacity;
      popups = cfg.opacity;
    };

    stylix.cursor = with pkgs; {
      package = phinger-cursors;
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
        package = maple-mono;
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
