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
    name: { metaConfig, nixosConfig }: metaConfig.withISO or false
  ) bases;

  configWithISO = lib.mapAttrs (name: value: value.nixosConfig) relevantHost;

  isoConfig = lib.mapAttrs' (
    name: config:
    lib.nameValuePair "${name}-iso" (
      (config.extendModules {
        modules = [
          (
            { modulesPath, pkgs, ... }:
            {
              boot.growPartition = true;
              fileSystems."/".autoResize = true;

              disko.imageBuilder = {
                enableBinfmt = true;
                # pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
                kernelPackages = pkgs.linuxPackages_latest;
              };
            }
          )
        ];
      }).config.system.build.diskoImages
    )
  ) configWithISO;
in
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = isoConfig;
    };
}
