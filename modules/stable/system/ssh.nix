{
  flake.nixosModules.ssh =
    {
      pkgs-unstable,
      pkgs,
      lib,
      config,
      ...
    }:
    {
      # TODO check if `config` & `options` work in this way
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
        settings = {
          UseDns = true;
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false; # whether keyboard-interactive authentication is allowed
          PermitRootLogin = "no";
        };
      };
    };
  flake.nixosModules.ssh-autostart =
    {
      pkgs-unstable,
      pkgs,
      lib,
      config,
      ...
    }:
    {
      services.openssh.enable = true;
    };
}
