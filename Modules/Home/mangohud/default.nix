{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.mangohud;
in {
  options.modules.mangohud = {
    enable = mkOption {
      description = "Enable MangoHud";
      type = types.bool;
      default = false;
    };
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
