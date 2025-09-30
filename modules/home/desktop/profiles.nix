{
  lib,
  config,
  libCustom,
  assets,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.desktop.profiles;
in {
  options.modules.desktop = {
    profiles = mkOption {
      description = "Profile to select";
      type = with types; (enum ["aestetic" "minimal" "work" "quickshell"]);
      default = "aestetic";
    };
  };

  config = mkMerge [
    # TODO WIP
    (mkIf (cfg == "aestetic") {
      modules = {
        apps.term.alacritty = mkDefault enabled;
        desktop = {
          wayland.hypr = {
            hyprland.enable = mkDefault true;
            hyprland.withEffects = mkDefault true;
            hyprland.rounding = mkDefault 10;
            hyprpanel = mkDefault enabled;
            hyprland.apps = {
              terminal = mkDefault (lib.getExe config.programs.alacritty.package);
            };
          };
          wayland.anyrun = mkDefault enabled;
          theme = {
            enable = mkDefault true;
            polarity = mkDefault "dark";
            theme = mkDefault "gruvbox-dark-medium";
            background-image = mkDefault assets.backgrounds.takopi;
          };
        };
      };
    })
    (mkIf (cfg == "quickshell") {
      modules = {
        desktop = {
          wayland.hypr = {
            hyprland.enable = mkDefault true;
            hyprland.withEffects = mkDefault true;
            hyprland.rounding = mkDefault 10;
            hyprpanel = mkDefault enabled;
          };
          wayland.anyrun = mkDefault enabled;
          theme = {
            enable = mkDefault true;
            polarity = mkDefault "dark";
            theme = mkDefault "gruvbox-dark-medium";
            background-image = mkDefault assets.backgrounds.background-2;
          };


          wayland.quickshell = enabled;
        };
      };
    })
    # TODO WIP
    (mkIf (cfg == "minimal") {
      modules = {
        desktop = {
          wayland.hypr = {
            hyprland.enable = mkDefault true;
            hyprland.withEffects = mkDefault false;
            hyprland.rounding = mkDefault 0;

            hyprpanel = mkDefault disabled;
          };
          wayland.anyrun = mkDefault enabled;
          theme = {
            enable = mkDefault false;
            polarity = mkDefault "dark";
            theme = mkDefault "gruvbox-dark-medium";
            opacity = mkDefault 1.0;
            background-image = mkDefault assets.backgrounds.background-2;
          };
        };
      };
    })
    # TODO
    (mkIf (cfg == "work") {
      })
  ];
}
