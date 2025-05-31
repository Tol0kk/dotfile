{
  pkgs,
  lib,
  config,
  assets,
  ...
}:
with lib; let
  cfg = config.modules.desktop.wayland.hypr;
in {
  # options.modules.desktop.wayland.hypr = {
  #   enable = mkOption {
  #     description = "Enable hypr enviroment configuration";
  #     type = types.bool;
  #     default = false;
  #   };
  #   minimal = mkOption {
  #     description = "Enable hypr with minimal effects";
  #     type = types.bool;
  #     default = false;
  #   };
  # };

  # config = mkMerge [
  #   (mkIf cfg.enable {
  #     specialisation.hyrp-minimal.configuration = {
  #       config.modules = {
  #         hypr.minimal = true;
  #         theme.background-image = assets.backgrounds.background-2;
  #         theme.opacity = 1.0;
  #       };
  #     };
  #   })
  # ];
}
