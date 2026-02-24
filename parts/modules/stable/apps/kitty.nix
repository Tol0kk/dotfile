{
  flake.homeModules.kitty =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          enable_audio_bell = false;
          "map f1" = "toggle_marker iregex 1 ERROR 2 WARNING 2 FAIL 2 FAILED 2 UNABLE 3 DEPRECATED ";
        };
      };
    };
}
