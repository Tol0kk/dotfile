{
  libDirs,
  lib,
  ...
}: {
  self,
  nixpkgs-stable,
  nixpkgs-unstable,
  ...
} @ inputs: let
  inherit (libDirs) get-directories;

  # Modules for the host
  host_modules = get-directories "${self}/Modules/Host";

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

  # Import Host folder
  hosts = get-directories "${self}/Host";
  hostsConfig =
    builtins.listToAttrs
    (builtins.map
      (host: {
        name = lib.strings.removeSuffix ".nix" (builtins.unsafeDiscardStringContext (builtins.baseNameOf host));
        value = import host inputs;
      })
      hosts);

  # Import Common Overlay
  common_overlay = import ./overlay.nix {inherit inputs self;};

  common_config = {
    name,
    nixpkgs,
  }: {
    networking.hostName = name;
    nix.registry.nixpkgs.flake = nixpkgs;

    nix.settings =
      {
        experimental-features = ["nix-command" "flakes"];
        builders-use-substitutes = true;
        warn-dirty = false;
        auto-optimise-store = true;
      }
      // (import "${self}/Lib/substituters.nix");
  };
in
  builtins.mapAttrs
  (
    name: {
      mainUser,
      system,
      nixpkgs,
      ...
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        pkgs = import nixpkgs {
          inherit system;
          hostPlatform.system = system;
          config = nixpkgs_config;
          overlays = common_overlay;
        };
        specialArgs =
          {
            inherit inputs self mainUser;
          }
          // libs // extraPkgs system;
        modules =
          [
            "${self}/Host/${name}/configuration.nix"
            "${self}/Host/${name}/hardware.nix"
            (common_config {inherit name nixpkgs;})
            inputs.nix-index-database.nixosModules.nix-index
            inputs.nix-topology.nixosModules.default
          ]
          ++ host_modules;
      }
  )
  hostsConfig
