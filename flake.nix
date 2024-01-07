{
  description = "My Nixos flake Configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mesa-demo = {
      url = "github:Tol0kk/Mesa-demos-8.4.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };


  outputs = { self, blender-bin, ... } @ inputs:
    {
      lib = import ./Lib inputs;
      nixosConfigurations = import ./Host inputs;
      homeConfigurations = import ./Home inputs;
      # templates = import ./Template;
    };
} 
