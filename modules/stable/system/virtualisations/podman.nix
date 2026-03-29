{
  flake.nixosModules.podman =
    {
      lib,
      pkgs,
      ...
    }:
    {
      virtualisation.podman.enable = true;
      virtualisation.podman.dockerSocket.enable = true;
      virtualisation.oci-containers = {
        backend = "podman";
      };
    };
}
