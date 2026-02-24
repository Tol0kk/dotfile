{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages.nixos-plymouth-custom = pkgs.callPackage ./nixos-plymouth-custom/package.nix { };
    };

  flake.overlays.default = final: prev: {
    nixos-plymouth-custom = final.callPackage ./nixos-plymouth-custom/package.nix { };
  };
}
