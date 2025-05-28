{nixpkgs-stable, ...} @ _inputs: let
  lib = nixpkgs-stable.lib;

  mkNixos = import ./mkNixos.nix {inherit lib libCustom;};
  mkTopology = import ./mkTopology.nix {inherit lib;};
  mkHome = import ./mkHome.nix {inherit lib libCustom;};
  mkColmena = import ./mkColmena.nix {inherit lib libCustom;};
  libCustom = import ./libCustom.nix {inherit lib;};
  libColor = import ./libColor.nix {inherit lib;};
in {
  inherit mkHome mkColmena libColor mkNixos libCustom mkTopology;
}
