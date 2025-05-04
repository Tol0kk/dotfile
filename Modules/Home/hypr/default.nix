{
  pkgs,
  inputs,
  lib,
  config,
  pkgs-stable,
  ...
}:
with lib; let
  cfg = config.modules.hypr;
in {
  options.modules.hypr = {
    enable = mkOption {
      description = "Enable hypr enviroment configuration";
      type = types.bool;
      default = false;
    };
    minimal = mkOption {
      description = "Enable hypr with minimal effects";
      type = types.bool;
      default = false;
    };
  };

  imports = [./hyprpanel.nix];

  config = mkMerge [
    {
      # programs.waybar = {
      #   enable = true;
      # };
    }
    (import ./hyprland.nix {
      inherit inputs pkgs lib config pkgs-stable;
    })
    {
      specialisation.hyrp-minimal.configuration = {
        config.modules = {
          hypr.minimal = true;
          theme.background-image = "${pkgs.assets}/background-2.png";
          theme.opacity = 1.0;
        };
      };
    }
  ];
}
