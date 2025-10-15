{
  libCustom,
  lib,
  ...
}:
{
  self,
  nixpkgs-stable,
  nixpkgs-unstable,
  home-manager-unstable,
  ...
}@inputs:
let
  inherit (libCustom) get-directories import-tree;

  common_overlay = import ./overlay.nix { inherit inputs self; };
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
  homes = get-directories "${self}/home";
  homeConfigs = builtins.listToAttrs (
    builtins.map (host: {
      name = lib.strings.removeSuffix ".nix" (
        builtins.unsafeDiscardStringContext (builtins.baseNameOf host)
      );
      value = import host inputs;
    }) homes
  );
in
builtins.mapAttrs (
  name:
  {
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
    extraSpecialArgs = {
      inherit inputs self username;
    }
    // libs
    // extraPkgs system;
    modules = [
      "${self}/home/${username}/home.nix"
      inputs.sops-nix.homeManagerModules.sops
      inputs.stylix.homeModules.stylix
      {
        home.stateVersion = "24.05";
        home.username = username;
        home.homeDirectory = /home/${username};
        programs.home-manager.enable = true;
        imports = [
          (import-tree "${self}/modules/home")
          (
            { config, ... }:
            {
              options.dotfiles = lib.mkOption {
                type = lib.types.path;
                apply = toString;
                default = "${config.home.homeDirectory}/.config/nixos";
                example = "${config.home.homeDirectory}/.config/nixos";
                description = "Location of the dotfiles working copy";
              };

            }
          )
        ];
      }
    ];
  }
) homeConfigs
