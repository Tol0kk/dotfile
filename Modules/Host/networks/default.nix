{
  pkgs,
  lib,
  config,
  libCustom,
  ...
}:
with lib; let
  cfg = config.modules.gaming;
  inherit (libCustom) get-directories;

  # Helper Function
  get-fileNameNoCtx = path:
    builtins.unsafeDiscardStringContext (builtins.baseNameOf path);
  get-networkFileName = path: "network-${get-fileNameNoCtx path}-file";

  # Get path of all the profiles
  profiles_dirs = get-directories ./_profiles;

  # Transform to sops secret to fetch secrets form directories
  # Secrets get map to network-<name>-file
  secrets_attrs = builtins.listToAttrs (builtins.map (dir: {
      name = get-networkFileName dir;
      value = {sopsFile = "${dir}/secrets.yaml";};
    })
    profiles_dirs);
  # EnvornmentFiles: Insert secrets path to env files used by network manager
  envFiles_list = builtins.map (dir: config.sops.secrets.${get-networkFileName dir}.path) profiles_dirs;
  # Profiles: Read profiles and insert them inside networkmanager under the porfile folder name;
  profiles = builtins.listToAttrs (builtins.map (dir: {
      name = get-fileNameNoCtx dir;
      value = import "${dir}/profile.nix";
    })
    profiles_dirs);
in {
  options.modules.network-profiles = {
    enable = mkOption {
      description = "Enable Network Profiles";
      type = types.bool;
      default = false;
    };
  };

  # config = mkIf cfg.enable {
  config = {
    # Add all the secrets from profiles
    sops.secrets = secrets_attrs;

    networking.networkmanager.ensureProfiles = {
      environmentFiles = envFiles_list;
      profiles = profiles;
    };
  };
}
