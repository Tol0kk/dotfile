{
  lib,
  config,
  libCustom,
  assets,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.desktop.profiles;
in
{
  options.modules.desktop = {
    profiles = mkOption {
      description = "Profile to select";
      type =
        with types;
        (enum [
          "aestetic"
          "minimal"
          "work"
        ]);
      default = "aestetic";
    };
  };

  config = mkMerge [
    # TODO WIP
    (mkIf (cfg == "aestetic") {
      modules = {
        apps.term.alacritty = mkDefault enabled;
        desktop = {
          wayland.shells.noctalia = mkDefault enabled;
          wayland.vicinae.enable = mkDefault true;
          wayland.niri = mkDefault enabled;
          theme = {
            enable = mkDefault true;
            opacity = mkDefault 0.92;
            polarity = mkDefault "dark";
            theme = mkDefault "gruvbox-dark-medium";
            background-image = mkDefault assets.backgrounds.takopi;
          };
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
