#Imported
{
  lib,
  libCustom,
  config,
  ...
}:

with lib;
with libCustom;
let
  cfg = config.modules.users.odin;
in
{
  options.modules.users.odin = {
    enable = mkEnableOpt "Enable Odin Users";
    isWheel = mkEnableOpt "is Odin Admin" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    users.users.odin = {
      isNormalUser = true;
      extraGroups = [
        # "networkmanager"
      ]
      ++ optionals cfg.isWheel [ "wheel" ];
      useDefaultShell = true;
      createHome = true;
    };
  };
}
