{lib}: let
  inherit (builtins) readDir pathExists unsafeDiscardStringContext baseNameOf listToAttrs map;
  inherit (lib) filterAttrs mapAttrsToList;
  inherit (lib.strings) removeSuffix hasSuffix;

  backgrounds = let
    backgroundsPath = ./backgrounds;
    safe-read-directory = path:
      if pathExists path
      then readDir path
      else {};
    is-regular-kind = kind: kind == "regular";
    is-png = name: kind: (is-regular-kind kind) && (hasSuffix ".png" name);
    entries = safe-read-directory backgroundsPath;
    filtered-entries = filterAttrs is-png entries;
    pngs =
      listToAttrs
      (map
        (file: {
          name = removeSuffix ".png" (unsafeDiscardStringContext (baseNameOf file));
          value = file;
        })
        filtered-entries);
  in
    pngs;
in {
  inherit backgrounds;
  shellAliases = import ./shellAliases.nix;
}
