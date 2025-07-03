{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.hardware.udev;
  extraRules =
    map
    (file: (pkgs.writeTextFile {
      name = file;
      destination = "/etc/udev/rules.d/${file}";
      text = builtins.readFile (./. + "/rules.d/${file}");
    }))
    (lib.attrNames
      (builtins.readDir ./rules.d));
in {
  options.modules.hardware.udev.enableExtraRules = mkEnableOpt "Enable extra rules";

  config = {
    services.udev.enable = true;
    services.udev.packages = mkIf cfg.enableExtraRules extraRules;
  };
}
