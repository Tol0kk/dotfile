# Improted
{
  lib,
  libCustom,
  config,
  pkgs-unstable,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.system.ssh;
in
{
  options.modules.system.ssh = {
    enable = mkEnableOpt "Enable SSH";
    auto-start-sshd = mkEnableOpt "Auto start sshd. By default no autostart";
  };

  config = mkIf cfg.enable {
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
    systemd.services.sshd.wantedBy = mkIf (!cfg.auto-start-sshd) (lib.mkForce [ ]);
  };
}
