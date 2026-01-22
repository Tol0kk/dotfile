{lib}: let
  inherit (builtins) readDir pathExists;
  inherit (lib) filterAttrs mapAttrsToList;

  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };
  mkOpt = type: default: description:
    lib.mkOption {inherit type default description;};
  mkBoolOpt = mkOpt lib.types.bool;
  mkEnableOpt = description: mkBoolOpt false description // {example = true;};

  get-directories = path: let
    is-directory-kind = kind: kind == "directory";
    safe-read-directory = path:
      if pathExists path
      then readDir path
      else {};
    entries = safe-read-directory path;
    filtered-entries = filterAttrs (name: kind: is-directory-kind kind) entries;
  in
    mapAttrsToList (name: kind: "${path}/${name}") filtered-entries;

  # Import tree function to get all .nix file recursicly in a directory, perfect for modules import
  import-tree = path: let
    module = {lib, ...}: {
      imports = leafs lib path;
    };

    leafs = lib: root: let
      isNixFile = lib.hasSuffix ".nix";
      notIgnored = p: !lib.hasInfix "/_" p;
      stringFilter = f: path: f (builtins.toString path);
      filterWithS = f: lib.filter (stringFilter f);
    in
      lib.pipe root [
        (lib.toList)
        (lib.lists.flatten)
        (lib.map lib.filesystem.listFilesRecursive)
        (lib.lists.flatten)
        (filterWithS isNixFile)
        (filterWithS notIgnored)
      ];

    result = {
      imports = [module];
    };
  in
    result;
in {
  inherit
    enabled
    get-directories
    import-tree
    disabled
    mkOpt
    mkBoolOpt
    mkEnableOpt
    ;
}
