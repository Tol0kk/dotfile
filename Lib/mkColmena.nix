{ self, nixpkgs-stable, nixpkgs-unstable, ... }@inputs:
nodes:

let
  host_modules = (
    builtins.map (dir: "${self}/Modules/Host/" + dir) (
      builtins.attrNames (builtins.readDir "${self}/Modules/Host")
    )
  );
  nixpkgs_config = {
    allowUnsupportedSystem = false;
    allowUnfree = true;
    experimental-features = "nix-command flakes";
    keep-derivations = true;
    keep-outputs = true;
  };

  common_overlay = [ ];
in
{
  meta = {
    # Never used every nodes overide this nixpkgs in nodeNixpkgs.
    nixpkgs = import nixpkgs-unstable {
      system = "x86_64-linux";
      overlays = common_overlay;
    };

    nodeSpecialArgs = builtins.mapAttrs
      (_name: { system, mainUser, ... }@value:
        let
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
        in
        {
          inherit inputs self pkgs-stable pkgs-unstable mainUser;
        }
      )
      nodes;

    nodeNixpkgs = builtins.mapAttrs
      (_name: { system, nixpkgs, ... }@value:
        import nixpkgs {
          inherit system;
          config = nixpkgs_config;
          overlays = common_overlay;
        }
      )
      nodes;
  };
} // builtins.mapAttrs
  (name: { allowLocalDeployment, ... }@value:
    {
      deployment = {
        inherit allowLocalDeployment;
      };

      imports = [
        "${self}/Host/${name}/configuration.nix"
        "${self}/Host/${name}/hardware.nix"
        {
            networking.hostName = name;
          nix.settings = {
            experimental-features = [ "nix-command" "flakes" ];
            builders-use-substitutes = true;
          } // (import "${self}/Lib/substituters.nix");
        }
        inputs.nix-index-database.nixosModules.nix-index
      ] ++ host_modules;
    }
  )
  nodes


