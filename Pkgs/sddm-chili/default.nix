{ stdenv, pkgs, username, ... }:
stdenv.mkDerivation rec {
  name = "sddm-chili";
  src = ./.;
  installPhase = ''
    mkdir -p $out/share/sddm/faces
    cp ./assets/${username}.face.icon $out/share/sddm/faces/${username}.face.icon 
  '';
}


