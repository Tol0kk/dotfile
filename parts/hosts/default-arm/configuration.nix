{
  self,
  ...
}:
{
  imports = [
    self.nixosModules.server-minimal
    self.nixosModules.gaia
  ];

  security.sudo.wheelNeedsPassword = false;
}
