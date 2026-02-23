{
  libCustom,
  ...
}:
with libCustom;
{
  # Modules
  modules = {
    users = {
      gaia = enabled;
    };
    system = {
      ssh.enable = true;
      ssh.auto-start-sshd = true;
    };
    archetype.server = enabled;
  };

  users.users.gaia = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
    ];
  };

  security.sudo.wheelNeedsPassword = false;

  nix.settings.trusted-users = [ "gaia" ];

  system.stateVersion = "25.11";
}
