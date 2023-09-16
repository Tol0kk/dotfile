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
            (builtins.readDir "${self}/Lib/colorrSchemes"))))
      (name: builtins.readFile
        ("${self}/Lib/colorrSchemes/" + name + ".nix"));
  defaultTheme = themes.Doom-One;
in
{
  options.modules.theme = {
    kitty-theme = mkOption {
      description = "Name of the theme (use for the name inside kitty)";
      type = types.str;
      default = defaultTheme.kitty-theme;
    };
    kind = mkOption {
      description = "";
      type = types.str;
      default = defaultTheme.kind;
    };
    colorSchemes = mkOption {
      description = "";
      type = attrsOf (types.str);
      default = {
        "aa" = "dd";
      };
    };
    gtk = {
      theme = mkOption {
        description = "";
        default = defaultTheme.gtk.theme;
      };
      iconTheme = mkOption {
        description = "";
        default = defaultTheme.gtk.iconTheme;
      };
      cursorTheme = mkOption {
        description = "";
        default = defaultTheme.gtk.cursorTheme;
      };
    };
    font = {
      name = mkOption {
        description = "";
        default = defaultTheme.font.name;
      };
      package = mkOption {
        description = "";
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
