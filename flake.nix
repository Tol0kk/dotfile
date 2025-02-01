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
    nvf.url = "github:notashelf/nvf";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-stable";
    anyrun = {
      url = "github:Kirottu/anyrun";
    };
  };

  outputs = {
    self,
    blender-bin,
    ...
  } @ inputs: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = inputs.nixpkgs-stable.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import inputs.nixpkgs-unstable {inherit system;});

    customNeovim = {
      pkgs,
      isMinimal,
      ...
    } @ args:
      inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [(import ./neovim args)];
      };
  in {
    lib = import ./Lib inputs;
    homeConfigurations = import ./Home inputs;
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      tiny-neovim =
        (customNeovim {
          inherit pkgs;
          isMinimal = true;
        })
        .neovim;
      neovim =
        (customNeovim {
          inherit pkgs;
          isMinimal = false;
        })
        .neovim;
    });

    colmena = import ./Lib/mkColmena.nix (inputs // {inherit customNeovim;}) {
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
