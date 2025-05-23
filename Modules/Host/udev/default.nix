{
  pkgs,
  lib,
  config,
  self,
  ...
}:
with lib; let
  cfg = config.modules.udev;
  extraRules =
    map
    (file: (pkgs.writeTextFile {
      name = file;
      destination = "/etc/udev/rules.d/${file}";
      text = builtins.readFile "${self}/Modules/Host/udev/rules.d/${file}";
    }))
    (lib.attrNames
      (builtins.readDir "${self}/Modules/Host/udev/rules.d"));
in {
  options.modules.udev.enableExtraRules = mkOption {
    description = "Enable extra rules";
    type = types.bool;
    default = false;
  };

  config = {
    services.udev.enable = true;
    services.udev.packages = mkIf cfg.enableExtraRules extraRules;
  };
}
