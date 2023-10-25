{ pkgs, lib, config, color, ... }:
with lib;
let
  cfg = config.modules.imv;
  themecfg = config.modules.theme;
  colorScheme = config.modules.theme.colorScheme;
  inherit (lib.strings) removePrefix;
in
{
  options.modules.imv = {
    enable = mkOption {
      description = "Enable imv";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.imv = {
      enable = true;
      settings = {
        options = {
          background = removePrefix "#" colorScheme.background;
          overlay = true;
          overlay_font = Monospace:8;
          overlay_background_color = removePrefix "#" colorScheme.background-alt;
          overlay_text_color = removePrefix "#" colorScheme.foreground;
          overlay_position_bottom = true;
        };
        aliases.x = "close";
      };
    };
  };
}

