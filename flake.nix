{
  description = "My Nixos flake Configuration";
  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    impermanence.url = "github:nix-community/impermanence";
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
    nix-topology.url = "github:oddlama/nix-topology";
    espflash.url = "github:esp-rs/espflash";
    espflash.flake = false;
    quickshell = {
      url = "git+https://git.outfoxxed.me/outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    fenix.url = "github:nix-community/fenix";
  };

  outputs = {
    self,
    blender-bin,
    ...
  } @ inputs: let
    supportedSystems = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-linux"
      "aarch64-darwin"
    ];
    forAllSystems = inputs.nixpkgs-stable.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import inputs.nixpkgs-unstable {inherit system;});
    lib = import ./lib inputs;
  in {
    homeConfigurations = lib.mkHome inputs;
    colmena = lib.mkColmena inputs;
    nixosConfigurations = lib.mkNixos inputs;

    # Apps / Packages provided by this flake
    packages = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
      in
        {
          inherit (pkgs.callPackage ./packages/neovim {inherit (inputs) nvf;}) tiny-neovim neovim;
          rkffmpeg = pkgs.callPackage ./packages/rkffmpeg {};
          linux-1_12-rockchip = pkgs.callPackage ./packages/linux-6.12-rockchip {};
        }
        // lib.mkOCI inputs pkgs
    );

    # Topology using https://github.com/oddlama/nix-topology
    topology = forAllSystems (system: lib.mkTopology system inputs self);
  };
}
