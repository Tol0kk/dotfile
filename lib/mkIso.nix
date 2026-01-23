{
  libCustom,
  lib,
  ...
}: {self, ...} @ inputs: pkgs: let
  inherit (libCustom) get-directories;
  systems = get-directories "${self}/systems";
  systemsConfig = builtins.listToAttrs (
    builtins.map (system: {
      name = lib.strings.removeSuffix ".nix" (
        builtins.unsafeDiscardStringContext (builtins.baseNameOf system)
      );
      value = import system inputs;
    })
    systems
  );

  isoTargets = lib.filterAttrs (_: config: config.withOCI or false) systemsConfig;
in
  pkgs.lib.mapAttrs' (
    name: _:
      pkgs.lib.nameValuePair "${name}-oci" (
        (self.nixosConfigurations.${name}.extendModules {
          modules = ["${pkgs.path}/nixos/modules/virtualisation/oci-image.nix"];
        }).config.system.build.OCIImage
      )
  )
  isoTargets
