{nixpkgs-stable, ...} @ inputs: let
  lib = nixpkgs-stable.lib;
in {
  mkSystem = import ./mkSystem.nix;
  mkHome = import ./mkHome.nix;
  mkColmena = import ./mkColmena.nix;
  libDirs = import ./libDirs.nix {inherit lib;};
  libColor = import ./libColor.nix {inherit lib;}; # TODO: rename color.nix to libColors
}
