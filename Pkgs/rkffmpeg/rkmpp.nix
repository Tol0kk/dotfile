{
  stdenv,
  pkgs,
  cmake,
  fetchFromGitHub,
  ...
}: let
  rockchip_mpp = stdenv.mkDerivation {
    name = "rockchip_mpp";
    version = "develop";

    src = fetchFromGitHub {
      owner = "rockchip-linux";
      repo = "mpp";
      rev = "ff3ae5c01044bab536a520a3c97f1ec85cb4f78b";
      sha256 = "sha256-5/5cUEL3OdjnmeVv8YarJnt/R/JH6JlJitvRpr8trhg=";
    };

    postPatch = ''
      substituteInPlace pkgconfig/rockchip_mpp.pc.cmake \
        --replace 'libdir=''${prefix}/'     'libdir=' \
        --replace 'includedir=''${prefix}/' 'includedir='
      substituteInPlace pkgconfig/rockchip_vpu.pc.cmake \
        --replace 'libdir=''${prefix}/'     'libdir=' \
        --replace 'includedir=''${prefix}/' 'includedir='
    '';

    nativeBuildInputs = [cmake];

    outputs = ["lib" "dev" "out"];
  };
in 
rockchip_mpp

