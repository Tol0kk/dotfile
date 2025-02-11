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
  ];
}
