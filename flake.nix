{
  description = "My Nixos flake Configuration";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-24.11";
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
    nvf.url = "github:notashelf/nvf";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-stable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    anyrun = {
      url = "github:Kirottu/anyrun";
    };
    nixpkgs-ondroid.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs-ondroid";
    };
    hyprpanel.url = "github:jas-singhfsu/hyprpanel";
    hyprpanel.inputs.nixpkgs.follows = "nixpkgs-unstable";
        nix-minecraft.url = "github:Infinidoge/nix-minecraft";
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
      (inputs.nvf.lib.neovimConfiguration {
        inherit pkgs;
        modules = [(import ./neovim args)];
      })
      .neovim;
    lib = import ./Lib inputs;
  in {
    lib = import ./Lib inputs; # TODO: Remove after mkHome rewrite
    homeConfigurations = import ./Home inputs;
    colmena = lib.mkColmena inputs;

    # Apps / Packages provided by this flake
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      tiny-neovim = customNeovim {
        inherit pkgs;
        isMinimal = true;
      };
      neovim = customNeovim {
        inherit pkgs;
        isMinimal = false;
      };
    });

    # nixOnDroidConfigurations.default = inputs.nix-on-droid.lib.nixOnDroidConfiguration {
    #   pkgs = import inputs.nixpkgs-ondroid {
    #     system = "aarch64-linux";
    #     overlays = [inputs.nix-on-droid.overlays.default];
    #   };
    #   modules = [
    #     ./Host/pixel8a.nix
    #     (builtins.map
    #       (dir: "${self}/Modules/Host/" + dir)
    #       (
    #         builtins.attrNames (builtins.readDir "${self}/Modules/Host")
    #       ))
    #   ];
    # };
  };
}
