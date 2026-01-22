{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.misc.thunderbird;
in {
  options.modules.apps.misc.thunderbird = {
    enable = mkEnableOpt "Enable Thunderbird";
  };

  # TODO configure
  config = mkIf cfg.enable {
    programs.thunderbird = {
      enable = true;
      profiles."default" = {
        isDefault = true;
      };
    };
  };
}
