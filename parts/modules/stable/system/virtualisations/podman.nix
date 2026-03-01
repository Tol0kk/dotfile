{
  flake.nixosModules.podman =
    {
      lib,
      pkgs,
      ...
    }:
    {
      virtualisation.podman.enable = true;
    };
}
