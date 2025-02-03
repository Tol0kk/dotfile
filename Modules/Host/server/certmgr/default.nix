{
  lib,
  pkgs,
  config,
  ...
}:
with lib; let
  cfg = config.modules.server.certmgr;
in {
  options.modules.server.certmgr = {
    enable = mkOption {
      description = "Enable certmgr service";
      type = types.bool;
      default = false;
    };
  };

  config =
    mkIf cfg.enable
    {
      services.certmgr.enable = true;
    };
}
