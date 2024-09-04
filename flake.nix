{
  description = "My Nixos flake Configuration";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    home-manager-stable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    mesa-demo = {
      url = "github:Tol0kk/Mesa-demos-8.4.0";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-stable";
    anyrun = {
      url = "github:Kirottu/anyrun";
    };
  };


  outputs = { self, blender-bin, ... } @ inputs:
    let
      conf = self.nixosConfigurations;
    in
    {
      lib = import ./Lib inputs;
      nixosConfigurations = import ./Host inputs;
      homeConfigurations = import ./Home inputs;

      colmena = {
        meta = {
          nixpkgs = import inputs.nixpkgs-stable {
            system = "aarch64-linux";
            overlays = [ ];
          };
          # nodeNixpkgs = builtins.mapAttrs (name: value: value.pkgs) conf;
          # nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) conf;
          # nodeNixpkgs = {
          #   laptop = import inputs.nixpkgs-unstable {
          #     system = "x86_64-linux";
          #     overlays = [ ];
          #   };
          # };
        };

        # laptop = { name, pkgs, lib, modulesPath, ... }: {


        #   networking.hostName = "laptop";
        # };

        servrock = { name, pkgs, lib, modulesPath, ... }: {
          deployment = {
            targetHost = "servrock";
            targetUser = "root";
          };

          imports = [
            ./Host/servrock/conf.nix
            ./Modules/Host/common
            {
              documentation.man = {
                enable = true;
                generateCaches = true;
              };
            }
          ];
        };
      };
      # // builtins.mapAttrs (name: value: { 
      #   deployment = inputs.nixpkgs-stable.lib.mkIf (name != "servrock") {
      #       targetHost = "servrock";
      #       targetUser = "root";
      #   };
      #   nixpkgs.hostPlatform =  inputs.nixpkgs-stable.lib.mkIf (name != "servrock") "aarch64-linux";
      #   imports = value._module.args.modules;

      #    }) conf;
      # templates = import ./Template;
    };
}
