{ self, ... }:
{
  flake.nixosModules.server =
    {
      libCustom,
      lib,
      ...
    }:
    with lib;
    with libCustom;
    {
      key = "nixosModules.server";
      imports = [
        self.nixosModules.sops
        self.nixosModules.ssh
        self.nixosModules.ssh-autostart

        self.nixosModules.traefik
      ];

      options.preferences = {
        openFirewall = mkEnableOpt "Allow Firewall";
        topDomain = mkOption {
          type = types.str;
        };
      };

      config = {
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
    };
}
