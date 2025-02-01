{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.glxgears;
in {
  options.modules.glxgears = {
    enable = mkOption {
      description = "Enable glxgears";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [inputs.mesa-demo.packages.${pkgs.system}.glxgears];
    xdg.configFile."glxgears/config.conf".text = with config.lib.stylix.colors; ''
      -col-red-gear #${base08}FF
      -col-green-gear #${base0B}FF
      -col-blue-gear #${base0D}FF
      -col-bg #${base00}CC
    '';
  };
}
