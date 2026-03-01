# Improted
{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.hardware.network;

  # Helper Function
  get-fileNameNoCtx = path: builtins.unsafeDiscardStringContext (builtins.baseNameOf path);
  get-networkFileName = path: "network-${get-fileNameNoCtx path}-file";

  # Get path of all the profiles
  profiles_dirs = get-directories ./_profilesWifi;

  # Transform to sops secret to fetch secrets form directories
  # Secrets get map to network-<name>-file
  secrets_attrs = builtins.listToAttrs (
    builtins.map (dir: {
      name = get-networkFileName dir;
      value = {
        sopsFile = "${dir}/secrets.yaml";
      };
    }) profiles_dirs
  );
  # EnvornmentFiles: Insert secrets path to env files used by network manager
  envFiles_list = builtins.map (
    dir: config.sops.secrets.${get-networkFileName dir}.path
  ) profiles_dirs;
  # Profiles: Read profiles and insert them inside networkmanager under the porfile folder name;
  profiles = builtins.listToAttrs (
    builtins.map (dir: {
      name = get-fileNameNoCtx dir;
      value = import "${dir}/profile.nix";
    }) profiles_dirs
  );
in
{
  options.modules.hardware.network = {
    wifi-profiles.enable = mkEnableOpt "Enable Wifi Profiles";
    avahi.enable = mkEnableOpt "Enable Dns";
  };

  config = mkMerge [
    (mkIf cfg.wifi-profiles.enable {
      assertions = [
        {
          assertion = config.sops.age.keyFile != null;
          message = ''
            You have to enable sops to use hardware.network.wifi-profiles.
          '';
        }
      ];

      # Add all the secrets from profiles
      sops.secrets = secrets_attrs;

      # networking.networkmanager.ensureProfiles = {
      #   environmentFiles = envFiles_list;
      #   profiles = profiles;
      # };
    })
    (mkIf cfg.avahi.enable {
      # TODO check this
      # Network discovery, mDNS
      # With this enabled, you can access your machine at <hostname>.local
      # it's more convenient than using the IP address.
      # https://avahi.org/
      services.avahi = {
        enable = true;
        nssmdns4 = true;
        publish = {
          enable = true;
          domain = true;
          userServices = true;
        };
      };
    })
  ];
}
