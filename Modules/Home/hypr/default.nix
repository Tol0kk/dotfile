{
  pkgs,
  lib,
  config,
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

  config = mkMerge [
    (mkIf cfg.enable {
      specialisation.hyrp-minimal.configuration = {
        config.modules = {
          hypr.minimal = true;
          theme.background-image = "${pkgs.assets}/background-2.png";
          theme.opacity = 1.0;
        };
      };
    })
  ];
}
