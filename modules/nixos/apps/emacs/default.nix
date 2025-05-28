{
  pkgs,
  libCustom,
  lib,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.emacs;
in {
  options.modules.apps.emacs = {
    enable = mkEnableOpt "Enable emacs";
  };

  config = mkIf cfg.enable {
    services.emacs.enable = true;
    services.emacs.package = pkgs.emacs-pgtk;
  };
}
