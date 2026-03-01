{
  flake.nixosModules.virtualBox =
    {
      lib,
      pkgs,
      ...
    }:
    {
      users.extraGroups.vboxusers.members = [ "user-with-access-to-virtualbox" ];
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.enableExtensionPack = true;
    };
}
