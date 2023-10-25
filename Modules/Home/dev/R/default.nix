{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev.languages.R;
in
{
  options.modules.dev.languages.R = {
    enable = mkOption {
      description = "Enable R language component";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      rstudio
    ];
  };
}
