{ self, nixpkgs-stable, nixpkgs-unstable, ... }@inputs:
{ hostname
, main_username
, nixpkgs
, system
, cudaSupport ? false
,
}:

nixpkgs.lib.nixosSystem (
  let
    configuration = "${self}/Host/${hostname}/configuration.nix";
    hardware = "${self}/Host/${hostname}/hardware.nix";
    overlays = (import ./overlay.nix { inherit inputs self; });

    pkgs = import nixpkgs {
      inherit system overlays;
      config = {
        allowUnsupportedSystem = false;
        allowBroken = false;
        allowUnfree = true;
        inherit cudaSupport;
        experimental-features = "nix-command flakes";
        keep-derivations = true;
        keep-outputs = true;
      };
    };

    pkgs-unstable = import nixpkgs-unstable {
      inherit system overlays;
      config = {
        allowUnsupportedSystem = false;
        allowBroken = false;
        allowUnfree = true;
        inherit cudaSupport;
        experimental-features = "nix-command flakes";
        keep-derivations = true;
        keep-outputs = true;
      };
    };

    pkgs-stable = import nixpkgs-stable {
      inherit system overlays;
      config = {
        allowUnsupportedSystem = false;
        allowBroken = false;
        allowUnfree = true;
        inherit cudaSupport;
        experimental-features = "nix-command flakes";
        keep-derivations = true;
        keep-outputs = true;
      };
    };

    host_modules = (
      builtins.map (dir: "${self}/Modules/Host/" + dir) (
        builtins.attrNames (builtins.readDir "${self}/Modules/Host")
      )
    );

    globalConfig = {
      boot.tmp.cleanOnBoot = true;
      networking.hostName = hostname;
      documentation.man = {
        enable = true;
        generateCaches = true;
      };
      nix.settings = {
        experimental-features = [ "nix-command" "flakes" ];
        builders-use-substitutes = true;
      } // (import ./substituters.nix);
    };
  in
  {
    inherit system pkgs;
    specialArgs = {
      inherit inputs self pkgs-stable pkgs-unstable;
      mainUser = main_username;
    };
    modules = [
      globalConfig
      configuration
      hardware
      inputs.nix-index-database.nixosModules.nix-index
    ] ++ host_modules;
  }
)
