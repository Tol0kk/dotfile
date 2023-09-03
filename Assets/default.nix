{ stdenv, pkgs, fetchurl, ... }:
stdenv.mkDerivation rec {
  name = "my-assets";
  src = ./.;

  installPhase = ''
  mkdir -p $out/Aa
  touch $out/Aa/test
'';

}


