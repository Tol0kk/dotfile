{
  self,
  lib,
  ...
}: let
  inherit (builtins) readDir pathExists;
  inherit (lib) assertMsg filterAttrs mapAttrsToList flatten;

  is-directory-kind = kind: kind == "directory";

  ## Safely read from a directory if it exists.
  ## Example Usage:
  ## ```nix
  ## safe-read-directory ./some/path
  ## ```
  ## Result:
  ## ```nix
  ## { "my-file.txt" = "regular"; }
  ## ```
  #@ Path -> Attrs
  safe-read-directory = path:
    if pathExists path
    then readDir path
    else {};

  ## Get directories at a given path.
  ## Example Usage:
  ## ```nix
  ## get-directories ./something
  ## ```
  ## Result:
  ## ```nix
  ## [ "./something/a-directory" ]
  ## ```
  #@ Path -> [Path]
  get-directories = path: let
    entries = safe-read-directory path;
    filtered-entries = filterAttrs (name: kind: is-directory-kind kind) entries;
  in
    mapAttrsToList (name: kind: "${path}/${name}") filtered-entries;

  server_modules = get-directories ./.;
  #  server_modules = (
  #    builtins.map
  #    (dir: "${self}/Modules/Host/server/" + dir)
  #    (
  #      builtins.filter
  #      (name: !lib.strings.hasSuffix ".nix" name || !lib.strings.hasSuffix ".yaml" name)
  #      (
  #        builtins.attrNames
  #        (builtins.readDir "${self}/Modules/Host/server/")
  #      )
  #    )
  #  );
in {
  imports = server_modules;
}
