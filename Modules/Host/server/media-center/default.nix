{libDirs, ...}: let
  inherit (libDirs) get-directories;
  modules = get-directories ./.;
in {
  imports = modules;
  # options.modules.server.media-center = {
  # enable = mkOption {
  #   description = "Enable Media Center";
  #   type = types.bool;
  #   default = false;
  # };
  # };

  # config =
  #   mkIf cfg.enable
  #   {

  #   };
}
