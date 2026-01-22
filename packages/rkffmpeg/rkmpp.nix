{
  stdenv,
  pkgs,
  cmake,
  fetchFromGitHub,
  lib,
  ...
}: let
  rockchip_mpp = stdenv.mkDerivation {
    name = "rockchip_mpp";
    version = "develop";

    src = fetchFromGitHub {
      owner = "rockchip-linux";
      repo = "mpp";
      rev = "4ed4f7786434ecf7c134ccf9af2d588794003972";
      sha256 = "sha256-VgogKrFJKqGSdmUNUHZM+9/e/2UmPA6WyndxkiNOJmA=";
    };

    postPatch = ''
      substituteInPlace pkgconfig/rockchip_mpp.pc.cmake \
        --replace 'libdir=''${prefix}/'     'libdir=' \
        --replace 'includedir=''${prefix}/' 'includedir='
      substituteInPlace pkgconfig/rockchip_vpu.pc.cmake \
        --replace 'libdir=''${prefix}/'     'libdir=' \
        --replace 'includedir=''${prefix}/' 'includedir='

      patchShebangs merge_static_lib.sh
      chmod +x merge_static_lib.sh
    '';

    nativeBuildInputs = [cmake];

    outputs = [
      "lib"
      "dev"
      "out"
    ];
  };
in
  rockchip_mpp
