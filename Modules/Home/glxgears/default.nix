{ pkgs, lib, config, inputs, ... }:
with lib;
let cfg = config.modules.glxgears;

in {
  options.modules.glxgears = {
    enable = mkOption {
      description = "Enable glxgears";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ inputs.mesa-demo.packages.${pkgs.system}.glxgears ];
    xdg.configFile."glxgears/config.conf".text = ''
      -col-red-gear #fb4934FF
      -col-green-gear #8ec07cFF
      -col-blue-gear #83a598FF
      -col-bg #282828CC
    '';
  };
}
