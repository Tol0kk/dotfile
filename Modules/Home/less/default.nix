{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.less;

in {
  options.modules.less = {
    enable = mkOption {
      description = "Enable less";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (pkgs.symlinkJoin {
        name = "less";
        paths = [ pkgs.less ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/less \
            --prefix LESSHISTFILE : "${config.xdg.dataHome}/lesshst"
        '';
      })
    ];
  };
}
