{ nixpkgs-stable, ... }@_inputs:
let
  lib = nixpkgs-stable.lib;

  mkBase = import ./mkBase.nix { inherit lib libCustom; };
  mkHost = import ./mkHost.nix { inherit lib libCustom mkBase; };
  libCustom = import ./libCustom.nix { inherit lib; };
  assets = import ../assets { inherit lib; };
  libColor = import ./libColor.nix { inherit lib; };
in
{
  inherit
    libColor
    libCustom
    mkHost
    assets
    ;
}
