{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.emacs;
in {
  options.modules.emacs = {
    enable = mkOption {
      description = "Enable emacs";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.emacs.enable = true;
    services.emacs.package = pkgs.emacs29-pgtk;
  };
}
