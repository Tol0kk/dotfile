
{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.thunar;

in {
  options.modules.thunar= {
    enable = mkOption {
      description = "Enable thunar";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.thunar = {
      enable = true;
			plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];
    };
  };
}
