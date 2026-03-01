{ self, ... }:
{
  flake.nixosModules.server = {
    imports = [
      self.nixosModules.sops
      self.nixosModules.ssh
      self.nixosModules.ssh-autostart
    ];
    # environment.shellInit = ''
    #   export TERM=xterm
    # '';

    # programs.command-not-found.enable = false;
    # documentation.enable = false;
    # services.printing.enable = false; # Removes cups/ghostscript

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
    };
  };
}
