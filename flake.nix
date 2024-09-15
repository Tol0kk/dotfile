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
    nixvim = {
      # TODO maybe create nixvim-stable and nixvim-unstable
      url = "github:nix-community/nixvim";
      # If using a stable channel you can use `url = "github:nix-community/nixvim/nixos-<version>"`
      inputs.nixpkgs.follows = "nixpkgs-unstable";
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
      # nixosConfigurations = import ./Host inputs;
      homeConfigurations = import ./Home inputs;

      colmena = import ./Lib/mkColmena.nix inputs {
        laptop = {
          system = "x86_64-linux";
          mainUser = "titouan";
          nixpkgs = inputs.nixpkgs-unstable;
          allowLocalDeployment = true;
        };
        desktop = {
          system = "x86_64-linux";
          mainUser = "titouan";
          nixpkgs = inputs.nixpkgs-unstable;
          allowLocalDeployment = true;
        };
        servrock = {
          system = "aarch64-linux";
          mainUser = "titouan";
          nixpkgs = inputs.nixpkgs-stable;
          allowLocalDeployment = false;
        };
      };
    };
}
