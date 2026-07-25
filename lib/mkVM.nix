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
    name: { metaConfig, nixosConfig }: metaConfig.withVM or false
  ) bases;

  configWithVM = lib.mapAttrs (name: value: value.nixosConfig) relevantHost;

  vmConfig = lib.mapAttrs' (
    name: config:
    lib.nameValuePair "${name}-vm" (
      (config.extendModules {
        modules = [
          (
            { modulesPath, ... }:
            {
              imports = [
                (modulesPath + "/virtualisation/qemu-vm.nix")
              ];
            }
          )
        ];
      }).config.system.build.vm
    )
  ) configWithVM;
in
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = vmConfig;
    };
}
