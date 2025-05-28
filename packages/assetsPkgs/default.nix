{
  stdenv,
  pkgs,
  ...
}:
stdenv.mkDerivation rec {
  name = "assets-pkgs-tol0kk";
  src = ./assets;
  installPhase = "mkdir $out; cp -r * $out/.";
}
