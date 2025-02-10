{
  self,
  lib,
  libDirs,
  ...
}: let
  inherit (libDirs) get-directories;
  server_modules = get-directories ./.;
in {
  imports = server_modules;
}
