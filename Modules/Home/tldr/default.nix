{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.tldr;

in {
  options.modules.tldr = {
    enable = mkOption {
      description = "Enable tldr";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (pkgs.symlinkJoin {
        name = "tldr";
        paths = [ pkgs.tldr ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/tldr \
            --prefix TLDR_CACHE_DIR : "${config.xdg.cacheHome}"
        '';
      })
    ];
  };
}
