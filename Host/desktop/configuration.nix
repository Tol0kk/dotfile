{mainUser, ...}: {
  modules = {
    bluetooth.enable = true;
    workstation = {
      enable = true;
      hypr.enable = true;
      gnome.enable = true;
    };
    fonts.enable = true;
    sops.enable = true;
    tools.security.enable = true;
    gaming.enable = true;
    nvidia.enable = true;
    boot.grub.enable = true;
    virtualisation.kvm.enable = true;
    neovim.custom.minimal = false;
  };

    users.users.${mainUser} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.enable = true;

  boot.binfmt.emulatedSystems = ["i686-linux" "aarch64-linux"];

  system.stateVersion = "24.05"; # Did you read the comment?
}
