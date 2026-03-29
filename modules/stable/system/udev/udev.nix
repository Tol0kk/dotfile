{
  flake.nixosModules.udev =
    {
      pkgs,
      lib,
      config,
      libCustom,
      ...
    }:
    let
      extraRules = map (
        file:
        (pkgs.writeTextFile {
          name = file;
          destination = "/etc/udev/rules.d/${file}";
          text = builtins.readFile (./. + "/rules.d/${file}");
        })
      ) (lib.attrNames (builtins.readDir ./rules.d));
    in
    {
      config = {
        services.udev.enable = true;
        services.udev.packages = extraRules;
      };
    };
}
