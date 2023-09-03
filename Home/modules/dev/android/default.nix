{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev.languages.android;
in
{
  options.modules.dev.languages.android = {
    enable = mkOption {
      description = "Enable Android Studio";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      android-tools
      android-studio
    ];
  };
}
