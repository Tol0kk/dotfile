{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.emacs;

in {
  options.modules.emacs = {
    enable = mkOption {
      description = "Enable Emacs";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ ];
    programs.emacs = {
      enable = true;
    };
  };
}
