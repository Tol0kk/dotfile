{
  self,
  lib,
  ...
}: let
  server_modules = (
    builtins.map
    (dir: "${self}/Modules/Host/server/" + dir)
    (
      builtins.filter
      (name: !lib.strings.hasSuffix ".nix" name)
      (
        builtins.attrNames
        (builtins.readDir "${self}/Modules/Host/server/")
      )
    )
  );
in {
  imports = server_modules;
}
