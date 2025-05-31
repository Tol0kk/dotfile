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
    is-image = name: (hasSuffix ".png" name) || (hasSuffix ".jpg" name);
    is-png = name: kind: (is-regular-kind kind) && is-image name;
    entries = safe-read-directory backgroundsPath;
    filtered-entries = builtins.attrNames (filterAttrs is-png entries);
    pngs =
      listToAttrs
      (map
        (file: let
          name = removeSuffix ".jpg" (removeSuffix ".png" (unsafeDiscardStringContext (baseNameOf file)));
        in {
          name = name;
          value = ./backgrounds/${file};
        })
        filtered-entries);
  in
    pngs;
in {
  backgrounds = backgrounds;
  shellAliases = import ./shellAliases.nix;
}
