{
  flake.nixosModules.odin = {
    users.users.odin = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      useDefaultShell = true;
      createHome = true;
    };
  };
}
