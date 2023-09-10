{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.general;

in {
  options.modules.general = {
    packages = mkOption {
      description = "Packages for home manager";
      type = types.listOf types.package;
      default = [ ];
    };
    sessionVariables = mkOption {
      description = "Packages for home manager";
      type = with types; lazyAttrsOf (oneOf [ str path int float ]);
      default = [ ];
    };
    sessionPath = mkOption {
      description = "Packages for home manager";
      type = with types; listOf str;
      default = [ ];
    };
  };

  config =
    (mkMerge [
      ({
        home.packages = cfg.packages;
      })
      ({
        home.sessionVariables = cfg.sessionVariables;
      })
      ({
        home.sessionPath = cfg.sessionPath;
      })
    ]);
}
