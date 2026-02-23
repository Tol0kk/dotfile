{
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.users.gaia;
in {
  options.modules.users.gaia = {
    enable = mkEnableOpt "Enable Gaia User";
    isWheel =
      mkEnableOpt "is Gaia Admin"
      // {
        default = true;
      };
  };

  config = mkIf cfg.enable {
    users.users.gaia = {
      isNormalUser = true;
      extraGroups = [] ++ optionals cfg.isWheel ["wheel"];
      useDefaultShell = true;
      createHome = true;
    };
  };
}
