{nixpkgs-stable, ...} @ inputs: let
  lib = nixpkgs-stable.lib;

  mkNixos = import ./mkNixos.nix {inherit lib libDirs;};
  mkHome = import ./mkHome.nix {inherit lib libDirs;};
  mkColmena = import ./mkColmena.nix {inherit lib libDirs;};
  libDirs = import ./libDirs.nix {inherit lib;};
  libColor = import ./libColor.nix {inherit lib;}; # TODO: rename color.nix to libColors
in {
  inherit mkHome mkColmena libDirs libColor mkNixos;
}
