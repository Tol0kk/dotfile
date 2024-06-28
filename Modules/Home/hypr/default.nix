{ pkgs, inputs, lib, config, ... }:
with lib;
let
  cfg = config.modules.hypr;
in
{
  options.modules.hypr = {
    enable = mkOption {
      description = "Enable hypr enviroment configuration";
      type = types.bool;
      default = false;
    };
  };

  config = mkMerge [
    {
      modules = {
        avizo.enable = true;
      };
    }
    (import ./hyprland.nix {
      inherit inputs pkgs lib config;
    })
  ];
}
