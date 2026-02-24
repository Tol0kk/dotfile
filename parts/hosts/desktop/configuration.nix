{ self, ... }:
{
  imports = [
    self.nixosModules.boot
    self.nixosModules.ssh
  ];

  modules = {
    system = {
      boot.limine.enable = true;
      boot.plymouth.enable = true;
    };
  };
}
