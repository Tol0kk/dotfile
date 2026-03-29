{
  libCustom,
  lib,
  mkBase,
  ...
}:
inputs:
let
  bases = mkBase inputs;

  relevantHost = lib.filterAttrs (
    name: { metaConfig, nixosConfig }: metaConfig.isNixos or false
  ) bases;

  nixosConfig = lib.mapAttrs (name: value: value.nixosConfig) relevantHost;
in
{
  flake.nixosConfigurations = nixosConfig;
}
