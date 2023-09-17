{ pkgs, lib, config, self, ... }:
with lib;
let
  cfg = config.modules.theme;
  # imports =
  # (builtins.map (dir: "${self}/Modules/Home/wayland/" + dir)
  #   (builtins.filter (name: !(hasSuffix ".nix" name))
  #     (builtins.attrNames (builtins.readDir "${self}/Modules/Home/wayland"))));
  # themes = import "${self}/Lib/colorSchemes" { inherit pkgs; };
  themes =
    lib.attrsets.genAttrs
      (lib.lists.flatten
        (builtins.map
          (name: lib.lists.take 1
            (lib.strings.splitString "." name))
          (builtins.attrNames
            (builtins.readDir "${self}/Lib/themes"))))
      (name: import "${self}/Lib/themes/${name}.nix" { inherit pkgs; });
  defaultTheme = themes.Doom-One;
in
{
  options.modules.theme = {
    kitty-theme = mkOption {
      description = "Name of the theme (use for the name inside kitty). Don't affect kitty themes only used to create the theme";
      type = types.str;
      default = defaultTheme.kitty-theme;
    };
    kind = mkOption {
      type = types.str;
      default = defaultTheme.kind;
    };
    base_opacity = mkOption {
      type = types.str;
      default = defaultTheme.base_opacity;
    };
    colorScheme = mkOption {
      default = defaultTheme.colorScheme;
    };
    gtk = {
      theme = mkOption {
        default = defaultTheme.gtk.theme;
      };
      iconTheme = mkOption {
        default = defaultTheme.gtk.iconTheme;
      };
      cursorTheme = mkOption {
        default = defaultTheme.gtk.cursorTheme;
      };
    };
    font = {
      name = mkOption {
        default = defaultTheme.font.name;
      };
      package = mkOption {
        default = defaultTheme.font.package;
      };
    };
  };

  config = {
    gtk = {
      enable = true;
      theme = cfg.gtk.theme;
      iconTheme = cfg.gtk.iconTheme;
      cursorTheme = cfg.gtk.cursorTheme;
    };
    # home.pointerCursor = {
    #   name = cfg.gtk.cursorTheme.name;
    #   package = cfg.gtk.cursorTheme.package;
    #   size = 48;
    #   gtk.enable = true;
    #   x11.enable = true;
    # };

    specialisation.Doom-One.configuration = {
      config.modules = {
        theme = themes.Doom-One;
      };
    };
    specialisation.Doom-One-Light.configuration = {
      config.modules = {
        theme = themes.Doom-One-Light;
      };
    };
    specialisation.Catppuccin-Mocha.configuration = {
      config.modules = {
        theme = themes.Catppuccin-Mocha;
      };
    };
  };


}
