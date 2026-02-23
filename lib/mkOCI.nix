{
  libCustom,
  lib,
  ...
}:
{ self, ... }@inputs:
pkgs:
let
  inherit (libCustom) get-directories;
  systems = get-directories "${self}/systems";
  systemsConfig = builtins.listToAttrs (
    builtins.map (system: {
      name = lib.strings.removeSuffix ".nix" (
        builtins.unsafeDiscardStringContext (builtins.baseNameOf system)
      );
      value = import system inputs;
    }) systems
  );

  isoTargets = lib.filterAttrs (_: config: config.withOCI or false) systemsConfig;
in
pkgs.lib.mapAttrs' (
  name: _:
  pkgs.lib.nameValuePair "${name}-oci" (
    (self.nixosConfigurations."${name}-base".extendModules {
      modules = [
        {
          # Disable boot because there is no bootloader needed for oci-image
          config.modules.system.boot.enable = lib.mkForce false;

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

        }
        "${pkgs.path}/nixos/modules/virtualisation/oci-image.nix"
      ];
    }).config.system.build.OCIImage
  )
) isoTargets
