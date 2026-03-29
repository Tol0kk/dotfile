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
    name: { metaConfig, nixosConfig }: metaConfig.withOCI or false
  ) bases;

  configWithOCI = lib.mapAttrs (name: value: value.nixosConfig) relevantHost;

  ociConfig = lib.mapAttrs' (
    name: config:
    lib.nameValuePair "${name}-oci" (
      (config.extendModules {
        modules = [
          (
            { modulesPath, ... }:
            {
              services.cloud-init = {
                enable = true;
                network.enable = true;
              };
              networking.useDHCP = false;
              systemd.network.enable = true;
              boot.initrd.availableKernelModules = [
                "virtio_net"
                "virtio_pci"
                "virtio_blk"
                "virtio_scsi"
                "9p"
                "9pnet_virtio"
              ];

              imports = [
                "${modulesPath}/virtualisation/oci-image.nix"
              ];
            }
          )
        ];
      }).config.system.build.OCIImage
    )
  ) configWithOCI;
in
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = ociConfig;
    };
}
