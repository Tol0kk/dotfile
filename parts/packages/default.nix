{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = {
        nixos-plymouth-custom = pkgs.callPackage ./nixos-plymouth-custom/package.nix { };
        inherit (pkgs.callPackage ./neovim/package.nix { inherit (inputs) nvf; }) tiny-neovim neovim;
      };
    };

  flake.overlays.default = final: prev: {
    nixos-plymouth-custom = final.callPackage ./nixos-plymouth-custom/package.nix { };
  };
}
