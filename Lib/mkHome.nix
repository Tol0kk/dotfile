{
  libCustom,
  lib,
  ...
}: {
  self,
  nixpkgs-stable,
  nixpkgs-unstable,
  home-manager-unstable,
  ...
} @ inputs: let
  inherit (libCustom) get-directories import-tree;

  common_overlay = import ./overlay.nix {inherit inputs self;};
  libs = import ./default.nix inputs;

  nixpkgs_config = {
    allowUnsupportedSystem = false;
    allowUnfree = true;
    experimental-features = "nix-command flakes";
    keep-derivations = true;
    keep-outputs = true;
  };

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
  homes = get-directories "${self}/Home";
  homeConfigs =
    builtins.listToAttrs
    (builtins.map
      (host: {
        name = lib.strings.removeSuffix ".nix" (builtins.unsafeDiscardStringContext (builtins.baseNameOf host));
        value = import host inputs;
      })
      homes);
in
  builtins.mapAttrs
  (
    name: {
      system,
      nixpkgs,
      username ? name,
      ...
    }:
      home-manager-unstable.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          hostPlatform.system = system;
          config = nixpkgs_config;
          overlays = common_overlay;
        };
        extraSpecialArgs =
          {
            inherit inputs self username;
          }
          // libs // extraPkgs system;
        modules = [
          "${self}/Home/${username}/home.nix"
          inputs.sops-nix.homeManagerModules.sops
          {
            home.stateVersion = "24.05";
            home.username = username;
            home.homeDirectory = /home/${username};
            programs.home-manager.enable = true;
            imports = [(import-tree "${self}/Modules/Home")];
          }
        ];
      }
  )
  homeConfigs
