{
  libCustom,
  lib,
  ...
}:
{ self, ... }@inputs:
baseSystemsConfig:
let
  inherit (libCustom) get-directories;
  systems = get-directories "${self}/systems";
  systemsConfig = builtins.listToAttrs (
    builtins.filter (item: item.value.isnixosConfigurations or true) (
      builtins.map (system: {
        name = lib.strings.removeSuffix ".nix" (
          builtins.unsafeDiscardStringContext (builtins.baseNameOf system)
        );
        value = import system inputs;
      }) systems
    )
  );

  hardware_path = config_name: "${self}/systems/${config_name}/hardware.nix";
in
lib.mapAttrs' (
  name: _:
  lib.nameValuePair "${name}" (
    (baseSystemsConfig."${name}-base".extendModules {
      modules = [
      ]
      ++ (if builtins.pathExists (hardware_path name) then [ (hardware_path name) ] else [ ]);
    })
  )
) systemsConfig
