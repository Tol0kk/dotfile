{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev.languages.java;
in
{
  options.modules.dev.languages.java = {
    enable = mkOption {
      description = "Enable java language component";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jdk17
    ];
    home.sessionVariables = {
      JDK_HOME = "${pkgs.jdk17}";
    };

  };
}
