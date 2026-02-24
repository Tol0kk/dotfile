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
      nixpkgs = if metaConfig.isUnstable then nixpkgs-unstable else nixpkgs-stable;
      nixosConfig = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit
            inputs
            self
            ;
          hostMetaOptions = metaConfig;
          pkgs-stable = import nixpkgs-stable {
            system = metaConfig.targetSystem;
            systemPlatform.system = metaConfig.targetSystem;
            config = nixpkgs_config;
          };
          # secrets = inputs.secrets;
        }
        // lib.optionalAttrs metaConfig.hasUnstable {
          pkgs-unstable = import nixpkgs-unstable {
            system = metaConfig.targetSystem;
            config = nixpkgs_config metaConfig;
          };
        }
        // import ./default.nix inputs;
        pkgs = import nixpkgs {
          system = metaConfig.targetSystem;
          systemPlatform.system = metaConfig.targetSystem;
          config = nixpkgs_config;
        };
        modules = [
          "${self}/hosts/${name}/configuration.nix"
          { nixpkgs.overlays = [ self.overlays.default ]; }
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
