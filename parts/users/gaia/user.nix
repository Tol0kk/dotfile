{
  flake.nixosModules.gaia = {
    users.users.gaia = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      useDefaultShell = true;
      createHome = true;
    };
  };
}
