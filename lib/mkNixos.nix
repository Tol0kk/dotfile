{
  libCustom,
  lib,
  ...
}: {
  self,
  nixpkgs-stable,
  nixpkgs-unstable,
  ...
} @ inputs: let
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

  # Import system folder
  systems = get-directories "${self}/systems";
  systemsConfig =
    builtins.listToAttrs
    (builtins.map
      (system: {
        name = lib.strings.removeSuffix ".nix" (builtins.unsafeDiscardStringContext (builtins.baseNameOf system));
        value = import system inputs;
      })
      systems);

  # Import Common Overlay
  common_overlay = import ./overlay.nix {inherit inputs self;};

  common_config = {
    name,
    nixpkgs,
  }: {
    nix.registry.nixpkgs.flake = nixpkgs;

    nix.settings =
      {
        experimental-features = ["nix-command" "flakes"];
        builders-use-substitutes = true;
        warn-dirty = false;
        auto-optimise-store = true;
      }
      // (import "${self}/lib/substituters.nix");
  };
in
  builtins.mapAttrs
  (
    name: {
      system,
      nixpkgs,
      withHomeManager ? false,
      ...
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          systemPlatform.system = system;
          config = nixpkgs_config;
          overlays = common_overlay;
        };
        specialArgs =
          {
            inherit inputs self withHomeManager;
          }
          // libs // extraPkgs system;
        modules =
          [
            "${self}/systems/${name}/configuration.nix"
            "${self}/systems/${name}/hardware.nix"
            (common_config {inherit name nixpkgs;})
            inputs.nix-index-database.nixosModules.nix-index
            inputs.nix-topology.nixosModules.default
            {imports = [(import-tree "${self}/modules/nixos")];}
            inputs.home-manager-unstable.nixosModules.home-manager
          ]
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
              home-manager.extraSpecialArgs =
                {
                  inherit inputs self;
                }
                // libs // extraPkgs system;
            }
          ];
      }
  )
  systemsConfig
