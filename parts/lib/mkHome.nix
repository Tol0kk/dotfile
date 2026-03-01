{
  lib,
  libCustom,
  ...
}:
{
  self,
  nixpkgs-unstable,
  nixpkgs-stable,
  home-manager-stable,
  home-manager-unstable,
  ...
}@inputs:
let
  # users = libCustom.getUsers self; # TODO

  hostsConfig = libCustom.getHostsConfig self; # format {<hostname> = {<hostConfig}}
  users = map (user_path: builtins.unsafeDiscardStringContext (builtins.baseNameOf user_path)) (
    libCustom.get-directories "${self}/users"
  );

  UsersHostCouple = builtins.listToAttrs (
    lib.flatten (
      map (
        user:
        map (hostName: {
          name = "${user}@${hostName}";
          value = {
            inherit user hostName;
            metaConfig = hostsConfig.${hostName};
          };
        }) (builtins.attrNames hostsConfig)
      ) users
    )
  );

  validUsersHostCouple = builtins.intersectAttrs self.homeModules UsersHostCouple;

  nixpkgs_config = metaOptions: {
    allowUnsupportedSystem = false;
    allowUnfree = metaOptions.allowUnfree;
    experimental-features = "nix-command flakes";
    keep-derivations = true;
    keep-outputs = true;
  };
in
{
  flake.homeConfigurations = lib.mapAttrs' (
    name:
    {
      user,
      hostName,
      metaConfig,
    }:
    lib.nameValuePair name (
      let
        libs = import ./default.nix inputs;
        home-manager = if metaConfig.isUnstable then home-manager-unstable else home-manager-stable;
        nixpkgs = if metaConfig.isUnstable then nixpkgs-unstable else nixpkgs-stable;
        nixpkgsconfig = {
          config = nixpkgs_config metaConfig;
          overlays = [ self.overlays.default ];
          systemPlatform.system = metaConfig.targetSystem;
          system = metaConfig.targetSystem;
        };

        homeConfig = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs nixpkgsconfig;
          extraSpecialArgs = {
            inherit
              self
              inputs
              libs
              nixpkgs
              nixpkgsconfig
              ;

            inherit (metaConfig) isPure;

            hostMetaOptions = metaConfig;
            pkgs-stable = import nixpkgs-stable nixpkgsconfig;
            # secrets = inputs.secrets;
          }
          // lib.optionalAttrs metaConfig.hasUnstable {
            pkgs-unstable = import nixpkgs-unstable nixpkgsconfig;
          }
          // libs;
          modules = [
            {
              home.username = user;
              home.homeDirectory = /home/${user};
            }
            self.homeModules.${name}
            self.homeModules.homemanager
          ];
        };
      in
      homeConfig
    )
  ) validUsersHostCouple;
}
