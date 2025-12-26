{
  libCustom,
  lib,
  ...
}:
{
  self,
  nixpkgs-stable,
  nixpkgs-unstable,
  ...
}@inputs:
let
  inherit (libCustom) get-directories import-tree;
  # Global Config
  nixpkgs_config = {
    allowUnsupportedSystem = false;
    allowUnfree = true;
    experimental-features = "nix-command flakes";
    keep-derivations = true;
    keep-outputs = true;
  };

  # Import Libs
  libs = import ./default.nix inputs;

  extraPkgs = system: {
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      overlays = common_overlay;
      config = nixpkgs_config;
    };

    pkgs-stable = import nixpkgs-stable {
      inherit system;
      overlays = common_overlay;
      config = nixpkgs_config;
    };
  };

  # Import systems folder
  systems = get-directories "${self}/systems";
  systemsConfig = builtins.listToAttrs (
    builtins.map (system: {
      name = lib.strings.removeSuffix ".nix" (
        builtins.unsafeDiscardStringContext (builtins.baseNameOf system)
      );
      value = import system inputs;
    }) systems
  );

  # Import Common Overlay
  common_overlay = import ./overlay.nix { inherit inputs self; };

  common_config =
    {
      name,
      nixpkgs,
    }:
    {
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
      }
      // (import "${self}/lib/substituters.nix");
    };
  hardware_path = config_name: "${self}/systems/${config_name}/hardware.nix";
in
{
  meta = {
    # Never used by any nodes. nodes overides this nixpkgs in nodeNixpkgs.
    nixpkgs = import nixpkgs-unstable {
      system = "x86_64-linux";
      overlays = common_overlay;
    };

    machinesFile = ./machines;

    nodeSpecialArgs = builtins.mapAttrs (
      _name:
      {
        system,
        withHomeManager ? false,
        isPure ? false,
        ...
      }:
      {
        inherit
          inputs
          self
          withHomeManager
          isPure

          ;
      }
      // libs
      // extraPkgs system
    ) systemsConfig;

    nodeNixpkgs = builtins.mapAttrs (
      _name:
      {
        system,
        nixpkgs,
        ...
      }:
      import nixpkgs {
        inherit system;
        hostPlatform.system = system;
        buildPlatform.system = "x86_64-linux";
        config = nixpkgs_config;
        overlays = common_overlay;
      }
    ) systemsConfig;
  };
}
// builtins.mapAttrs (
  name:
  {
    system,
    allowLocalDeployment,
    targetUser ? null, # TODO create a standalone user for deployment
    targetHost ? name,
    withHomeManager ? false,
    isPure ? false,
    nixpkgs,
    ...
  }:
  {
    deployment = {
      inherit allowLocalDeployment targetHost targetUser;
    };

    imports = [
      "${self}/systems/${name}/configuration.nix"
      (common_config { inherit name nixpkgs; })
      inputs.nix-index-database.nixosModules.nix-index
      inputs.nix-topology.nixosModules.default
      { imports = [ (import-tree "${self}/modules/nixos") ]; }
      inputs.home-manager-unstable.nixosModules.home-manager
    ]
    ++ (if builtins.pathExists (hardware_path name) then [ (hardware_path name) ] else [ ])
    ++ lib.optionals withHomeManager [
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "homeManagerBackup";
        home-manager.sharedModules = [
          {
            home.stateVersion = "24.05";
            programs.home-manager.enable = true;
          }
          (import-tree "${self}/modules/home")
          inputs.sops-nix.homeManagerModules.sops
        ];
        home-manager.extraSpecialArgs = {
          inherit
            inputs
            self
            isPure
            ;
        }
        // libs
        // extraPkgs system;
      }
    ];
  }
) systemsConfig
