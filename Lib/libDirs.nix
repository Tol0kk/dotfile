{lib}: let
  inherit (builtins) readDir pathExists;
  inherit (lib) filterAttrs mapAttrsToList;
in rec {
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
}
