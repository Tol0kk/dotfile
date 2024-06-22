{ self, ... }@inputs:
{ hostname
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
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
    };
  in
  {
    inherit system pkgs;
    specialArgs = {
      inherit inputs self;
    };
    modules = [
      globalConfig
      configuration
      hardware
      inputs.sops-nix.nixosModules.sops
      inputs.nix-index-database.nixosModules.nix-index
    ] ++ host_modules;
  }
)
