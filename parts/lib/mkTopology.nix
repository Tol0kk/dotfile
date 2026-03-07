{
  libCustom,
  lib,
  ...
}:
inputs:
{
  self,
  ...
}:
{
  perSystem = {
    topology.modules = [
      # "${self}/systems/topology.nix"
    ];
  };
}
