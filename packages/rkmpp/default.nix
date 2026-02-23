{
  stdenv,
  pkgs,
  cmake,
  fetchFromGitHub,
  ...
}:
let
  rockchip_mpp = stdenv.mkDerivation {
    name = "rockchip_mpp";
    version = "develop";

    src = fetchFromGitHub {
      owner = "rockchip-linux";
      repo = "mpp";
      rev = "4ed4f7786434ecf7c134ccf9af2d588794003972";
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

    nativeBuildInputs = [ cmake ];

    outputs = [
      "lib"
      "dev"
      "out"
    ];
  };
in
rockchip_mpp
