{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.kitty;
  # themecfg = config.modules.theme;
  # colorScheme = config.modules.theme.colorScheme;
  inherit (lib.strings) floatToString;
in {
  options.modules.kitty = {
    enable = mkOption {
      description = "Enable kitty";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      settings = {
        confirm_os_window_close = 0;
        enable_audio_bell = false;
        "map f1" = "toggle_marker iregex 1 ERROR 2 WARNING 2 FAIL 2 FAILED 2 UNABLE 3 DEPRECATED ";
      };
    };

    home.sessionVariables = {
      MY_TERM = "${pkgs.kitty}/bin/kitty";
    };
  };
}
