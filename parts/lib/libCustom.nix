{ lib }:
let
  inherit (builtins) readDir pathExists;
  inherit (lib) filterAttrs mapAttrsToList;
  inherit (lib) types mkOption;

  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };
  mkOpt =
    type: default: description:
    lib.mkOption { inherit type default description; };
  mkBoolOpt = mkOpt lib.types.bool;
  mkEnableOpt = description: mkBoolOpt false description // { example = true; };

  get-directories =
    path:
    let
      is-directory-kind = kind: kind == "directory";
      safe-read-directory = path: if pathExists path then readDir path else { };
      entries = safe-read-directory path;
      filtered-entries = filterAttrs (name: kind: is-directory-kind kind) entries;
    in
    mapAttrsToList (name: kind: "${path}/${name}") filtered-entries;

  # Import tree function to get all .nix file recursicly in a directory, perfect for modules import
  import-tree =
    path:
    let
      module =
        { lib, ... }:
        {
          imports = leafs lib path;
        };

      leafs =
        lib: root:
        let
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
        imports = [ module ];
      };
    in
    result;

  getHostsConfig =
    self:
    let
      importIfExists = path: default: if builtins.pathExists path then import path else default;
      systems = get-directories "${self}/hosts";
      systemsConfig = builtins.listToAttrs (
        builtins.map (system: {
          name = lib.strings.removeSuffix ".nix" (
            builtins.unsafeDiscardStringContext (builtins.baseNameOf system)
          );
          value = importIfExists "${system}/default.nix" { };
        }) systems
      );

      # Define meta confiration
      hostMetaOptions = {
        options.hostMeta = {
          targetSystem = mkOption {
            type = types.str;
            description = "What system to target for this host";
          };
          withHomeManager = mkOption {
            type = types.bool;
            default = false;
            description = "If we use the home configuration directly inside the nixos system";
          };
          isUnstable = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to use unstable channel as default for pkgs";
          };
          hasUnstable = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to add unstable channel as pkgs-unstable";
          };
          isPure = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to unable pure path or not. Used for home configuration, symlink direclty to configration is impure";
          };
          withOCI = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to add a <host>-oci for generating an oci image (.qwoc2)";
          };
          withISO = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to add a <host>-iso for generating an iso image";
          };
          stateVersion = mkOption {
            type = types.str;
            description = "NixOS state version for this host";
          };
          homeStateVersion = mkOption {
            type = types.str;
            description = "Home Manager state version for this host";
          };
          allowUnfree = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to allow unfree packages";
          };
          isNixos = mkOption {
            type = types.bool;
            default = true;
            description = "Whether to generate a nixosConfiguration for this host";
          };
          isAndroid = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to generate a Nix-droid for this host";
          };
          remote = mkOption {
            default = { };
            description = "Remote build configuration";
            type = (
              types.submodule {
                options = {
                  targetHost = mkOption {
                    type = types.nullOr types.str;
                    description = "The target host (domain or ip) for remote build";
                    default = null;
                  };
                  targetUser = mkOption {
                    type = types.nullOr types.str;
                    description = "The target user for remote build";
                    default = null;
                  };
                };
              }
            );
          };
        };
      };

      # Evaluate each configration with meta configuration :)
      evalHostMeta =
        rawData:
        let
          result = lib.evalModules {
            modules = [
              hostMetaOptions
              { hostMeta = rawData; }
            ];
          };
        in
        result.config.hostMeta;

      attr = lib.mapAttrs' (name: content: lib.nameValuePair name (evalHostMeta content)) systemsConfig;
    in
    attr;

  mkSource =
    isPure: relPath: absPath:
    if isPure then relPath else lib.file.mkOutOfStoreSymlink absPath;

in
{
  inherit
    enabled
    get-directories
    import-tree
    disabled
    mkOpt
    mkBoolOpt
    mkEnableOpt
    getHostsConfig
    mkSource
    ;
}
