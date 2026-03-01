{
  inputs = {
    # Unstable
    #
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    stylix-unstable.url = "github:danth/stylix";
    stylix-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs-unstable";
    noctalia.url = "github:noctalia-dev/noctalia-shell";
    noctalia.inputs.nixpkgs.follows = "nixpkgs-unstable";
    vicinae.url = "github:vicinaehq/vicinae"; # We use the nixpkgs from vicinar for cachix
    vicinae-extensions.url = "github:vicinaehq/extensions";
    vicinae-extensions.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # Stable
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager-stable.url = "github:nix-community/home-manager";
    home-manager-stable.inputs.nixpkgs.follows = "nixpkgs-stable";
    stylix-stable.url = "github:danth/stylix";
    stylix-stable.inputs.nixpkgs.follows = "nixpkgs-stable";

    # Both
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
    sops-nix.url = "github:Mic92/sops-nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nvf.url = "github:notashelf/nvf";
    import-tree.url = "github:vic/import-tree";
    nix-topology.url = "github:oddlama/nix-topology";
    git-hooks.url = "github:cachix/git-hooks.nix";
  };

  # TODO don't import everythings
  outputs =
    inputs:
    let
      lib = import ./lib inputs;
    in
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.home-manager-stable.flakeModules.home-manager
        (inputs.import-tree [
          ./miscs
          ./shells
          ./users
          ./templates
          ./modules/stable
          ./modules/unstable
        ])
        ./packages
        (lib.mkHost inputs)
      ];
    };
}
