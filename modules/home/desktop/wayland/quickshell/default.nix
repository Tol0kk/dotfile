{
  pkgs,
  lib,
  config,
  libCustom,
  inputs,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.desktop.wayland.quickshell;
in {
  options.modules.desktop.wayland.quickshell = {
    enable = mkEnableOpt "Enable quickshell";
  };

  # TODO
  config = mkIf cfg.enable {
    home.packages = [inputs.quickshell.packages.${pkgs.system}.default];
  };
}
