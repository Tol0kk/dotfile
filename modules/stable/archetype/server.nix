{ self, ... }:
{
  flake.nixosModules.server-minimal =
    {
      libCustom,
      lib,
      ...
    }:
    with lib;
    with libCustom;
    {
      key = "nixosModules.server-minimal";
      imports = [
        self.nixosModules.sops
        self.nixosModules.ssh
        self.nixosModules.ssh-autostart
      ];

      options.preferences = {
        openFirewall = mkEnableOpt "Allow Firewall";
        public = mkEnableOpt "Is the host publicly accesible";
        sso = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        netbird-api = mkOption {
          type = types.nullOr types.str;
          default = null;
        };
        topDomain = mkOption {
          type = types.str;
        };
      };

      config = {
        environment.shellInit = ''
          export TERM=xterm
        '';

        # programs.command-not-found.enable = false;
        # documentation.enable = false;
        # services.printing.enable = false; # Removes cups/ghostscript

        documentation.enable = false;
        documentation.nixos.enable = false;
        documentation.man.enable = false;
        documentation.info.enable = false;
        documentation.doc.enable = false;

        services.logrotate.enable = true;
        system.autoUpgrade = {
          enable = true;
          allowReboot = true;
        };

        nix.settings.auto-optimise-store = true;

        networking.firewall = {
          enable = true;
          allowedTCPPorts = [
            22
          ];
        };
      };
    };

  flake.nixosModules.server = {
    imports = [
      self.nixosModules.server-minimal
      self.nixosModules.traefik
    ];
  };
}
