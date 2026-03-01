# Create a host by importing the right modules based on its default.nix configuration
{
  libCustom,
  lib,
  ...
}:
{
  self,
  nixpkgs-unstable,
  nixpkgs-stable,
  ...
}@inputs:
let
  hostsConfig = libCustom.getHostsConfig self;

  nixpkgs_config = metaOptions: {
    allowUnsupportedSystem = false;
    allowUnfree = metaOptions.allowUnfree;
    experimental-features = "nix-command flakes";
    keep-derivations = true;
    keep-outputs = true;
  };
in
lib.mapAttrs' (
  name: metaConfig:
  lib.nameValuePair name (
    let
      libs = import ./default.nix inputs;
      nixpkgs = if metaConfig.isUnstable then nixpkgs-unstable else nixpkgs-stable;
      nixosConfig = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            self
            inputs
            libs
            nixpkgs
            ;
          hostMetaOptions = metaConfig;
          pkgs-stable = import nixpkgs-stable {
            system = metaConfig.targetSystem;
            systemPlatform.system = metaConfig.targetSystem;
            config = nixpkgs_config metaConfig;
            overlays = [ self.overlays.default ];
          };
          # secrets = inputs.secrets;
        }
        // lib.optionalAttrs metaConfig.hasUnstable {
          pkgs-unstable = import nixpkgs-unstable {
            system = metaConfig.targetSystem;
            config = nixpkgs_config metaConfig;
            overlays = [ self.overlays.default ];
          };
        }
        // libs;
        pkgs = import nixpkgs {
          system = metaConfig.targetSystem;
          systemPlatform.system = metaConfig.targetSystem;
          config = nixpkgs_config metaConfig;
          overlays = [ self.overlays.default ];
        };
        modules = [
          "${self}/hosts/${name}/configuration.nix"
          self.nixosModules.common
          inputs.nix-topology.nixosModules.default
        ]
        ++ lib.optionals (builtins.pathExists "${self}/hosts/${name}/hardware.nix") [
          "${self}/hosts/${name}/hardware.nix"
        ]
        ++ lib.optionals (builtins.pathExists "${self}/hosts/${name}/disko.nix") [
          "${self}/hosts/${name}/disko.nix"
        ]
        ++ [
          {
            system.stateVersion = metaConfig.stateVersion;
            networking.hostName = name;
            nix.registry.nixpkgs.flake = nixpkgs;

            nix.settings = {
              experimental-features = [
                "nix-command"
                "flakes"
              ];
              builders-use-substitutes = true;
              warn-dirty = false;
              auto-optimise-store = true;
            };
          }
        ];
      };
    in
    {
      inherit nixosConfig metaConfig;
    }
  )
) hostsConfig
