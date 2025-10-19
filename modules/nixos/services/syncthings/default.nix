{
  libCustom,
  lib,
  config,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.services.restic;
in
{
  options.modules.services.syncthings = {
    enable = mkEnableOpt "Enable Sync";
  };

  # TODO check
  config = mkIf cfg.enable {

  };
}
