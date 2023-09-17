{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.tldr;

in {
  options.modules.tldr = {
    enable = mkOption {
      description = "Enable tldr";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      TLDR_CACHE_DIR = "$XDG_CACHE_HOME/tldrc";
    };
    home.packages = with pkgs; [
      tldr
    ];
  };
}
