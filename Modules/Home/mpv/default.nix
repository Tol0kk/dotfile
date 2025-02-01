{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.mpv;
in {
  options.modules.mpv = {
    enable = mkOption {
      description = "Enable MPV";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.mpv = {
      enable = true;
    };
  };
}
