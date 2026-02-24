{
  flake.nixosModules.ssh =
    {
      pkgs-unstable,
      pkgs,
      lib,
      config,
      ...
    }:
    let
      inherit (lib) mkOption types mkIf;
      cfg = config.preferences.ssh;
    in
    {
      options.preferences.ssh = {
        auto-start = mkOption {
          type = types.bool;
          default = false;
        };
      };

      # TODO check if `config` & `options` work in this way
      config = {
        programs.ssh = {
          extraConfig = ''
            Host servrock.tolok.org
              ProxyCommand ${pkgs-unstable.cloudflared}/bin/cloudflared access ssh --hostname %h
            Host desktop.tolok.org
              ProxyCommand ${pkgs-unstable.cloudflared}/bin/cloudflared access ssh --hostname %h
            Host laptop.tolok.org
              ProxyCommand ${pkgs-unstable.cloudflared}/bin/cloudflared access ssh --hostname %h
          '';
        };

        services.openssh = {
          enable = true;
          settings = {
            UseDns = true;
            PasswordAuthentication = false;
            KbdInteractiveAuthentication = false; # whether keyboard-interactive authentication is allowed
            PermitRootLogin = "no";
          };
        };
        systemd.services.sshd.wantedBy = mkIf (!cfg.auto-start) (lib.mkForce [ ]);
      };
    };
}
