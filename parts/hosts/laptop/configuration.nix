{ self, ... }:
{
  imports = [
    self.nixosModules.limine
    self.nixosModules.plymouth
    self.nixosModules.ssh
  ];

  networking.hostId = "0be1cd29";
}
