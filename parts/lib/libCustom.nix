{ lib }:
let
  inherit (builtins)
    readDir
    pathExists
    toString
    baseNameOf
    unsafeDiscardStringContext
    listToAttrs
    ;

  inherit (lib)
    filterAttrs
    mapAttrsToList
    mkOption
    types
    pipe
    toList
    flatten
    map
    filesystem
    filter
    hasSuffix
    hasInfix
    evalModules
    ;

  # --- Option Helpers ---
  enabled = {
    enable = true;
  };
  disabled = {
    enable = false;
  };

  mkOpt =
    type: default: description:
    mkOption { inherit type default description; };
  mkBoolOpt = mkOpt types.bool;
  mkEnableOpt = description: mkBoolOpt false description // { example = true; };

  # --- Directory Helpers ---
  get-directories =
    path:
    if !pathExists path then
      [ ]
    else
      pipe path [
        readDir
        (filterAttrs (_name: kind: kind == "directory"))
        (mapAttrsToList (name: _kind: "${toString path}/${name}"))
      ];

  import-tree = path: {
    imports = pipe path [
      toList
      flatten
      (map filesystem.listFilesRecursive)
      flatten
      (filter (
        p:
        let
          pStr = toString p;
        in
        hasSuffix ".nix" pStr && !(hasInfix "/_" pStr)
      ))
    ];
  };

  # --- Host Configuration Logic ---
  getHostsConfig =
    self:
    let
      importIfExists = path: default: if pathExists path then import path else default;

      # Define meta configuration schema
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
            default = true;
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
            type = types.submodule {
              options = {
                targetHost = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                  description = "The target host (domain or ip) for remote build";
                };
                targetUser = mkOption {
                  type = types.nullOr types.str;
                  default = null;
                  description = "The target user for remote build";
                };
              };
            };
          };
        };
      };

      # Evaluates raw data against the module schema
      evalHostMeta =
        rawData:
        (evalModules {
          modules = [
            hostMetaOptions
            { hostMeta = rawData; }
          ];
        }).config.hostMeta;

    in
    pipe "${self}/hosts" [
      get-directories
      (map (systemPath: {
        # Extract the directory name as the hostname
        name = unsafeDiscardStringContext (baseNameOf systemPath);

        # Import the default.nix and immediately evaluate it against our schema
        value = evalHostMeta (importIfExists "${systemPath}/default.nix" { });
      }))
      listToAttrs
    ];

  # --- File Symlink Helper ---
  mkSource =
    isPure: relPath: absPath:
    if isPure then relPath else lib.file.mkOutOfStoreSymlink absPath; # Note: requires config.lib.file in HM context!

in
{
  inherit
    enabled
    disabled
    mkOpt
    mkBoolOpt
    mkEnableOpt
    get-directories
    import-tree
    getHostsConfig
    mkSource
    ;
}
