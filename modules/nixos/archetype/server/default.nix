{
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.archetype.server;
in {
  options.modules.archetype.server = {
    enable = mkEnableOpt "Enable server archetype";
  };

  # TODO replace modules/nixos/server
  config = mkIf cfg.enable {
    hardware.graphics = {
      enable = true;
      # enable32Bit = true; # Only support x86_64
    };
  };
}
