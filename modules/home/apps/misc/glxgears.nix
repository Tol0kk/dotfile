{
  pkgs,
  lib,
  config,
  inputs,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.misc.glxgears;
in {
  options.modules.apps.misc.glxgears = {
    enable = mkEnableOpt "Enable glxgears";
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
