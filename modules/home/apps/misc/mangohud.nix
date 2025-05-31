{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.misc.mangohud;
in {
  options.modules.apps.misc.mangohud = {
    enable = mkEnableOpt "Enable MangoHud";
  };

  config = mkIf cfg.enable {
    programs.mangohud = {
      enable = true;
      enableSessionWide = false; # Enable MangoHud on all application that support it # TODO allow switch
      settings = {
        # See https://github.com/flightlessmango/MangoHud/blob/master/data/MangoHud.conf
        full = true;
      };
    };
  };
}
