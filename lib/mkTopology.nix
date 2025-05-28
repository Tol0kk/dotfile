{lib, ...}: let
  topology = system: inputs: self:
    import inputs.nix-topology {
      pkgs = import inputs.nixpkgs-unstable {
        inherit system;
        overlays = import ./overlay.nix {inherit inputs self;};
      };
      modules = [
        # Your own file to define global topology. Works in principle like a nixos module but uses different options.
        "${self}/systems/topology.nix"
        # Inline module to inform topology of your existing NixOS hosts.
        {nixosConfigurations = self.nixosConfigurations;}
      ];
    };
in
  topology
