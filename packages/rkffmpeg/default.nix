{
  stdenv,
  pkgs,
  cmake,
  fetchFromGitHub,
  callPackage,
  darwin,
  cudaPackages,
  ...
}: let
  rockchip_mpp = callPackage ./rkmpp.nix {};
  mkFFmpeg = initArgs: ffmpegVariant:
    callPackage ./generic.nix (
      {
        inherit (darwin) xcode;
        inherit (cudaPackages) cuda_cudart cuda_nvcc libnpp;
        inherit rockchip_mpp;
      }
      // (initArgs // {inherit ffmpegVariant;})
    );
  v7 = {
    version = "7.1.1";
    hash = "sha256-GyS8imOqfOUPxXrzCiQtzCQIIH6bvWmQAB0fKUcRsW4=";
  };
  rkffmpeg = mkFFmpeg v7 "full";
in
  rkffmpeg.override {
    withRkmpp = true;
  }
