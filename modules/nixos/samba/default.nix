{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.samba;
in {
  options.modules.samba = {
    enable = mkOption {
      description = "Enable samba";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
    networking.firewall.allowedTCPPorts = [
      5357 # wsdd
    ];
    networking.firewall.allowedUDPPorts = [
      3702 # wsdd
    ];

    networking.firewall.enable = true;
    networking.firewall.allowPing = true;
    services.samba.openFirewall = true;

    services.samba = {
      enable = true;
      securityType = "user";
      extraConfig = ''
        workgroup = WORKGROUP
        server string = smbnix
        netbios name = smbnix
        security = user
        #use sendfile = yes
        #max protocol = smb2
        # note: localhost is the ipv6 localhost ::1
        hosts allow = 192.168.1. 192.168.0. 127.0.0.1 localhost
        hosts deny = 0.0.0.0/0
        guest account = nobody
        map to guest = bad user
      '';
      shares = {
        public = {
          path = "/mnt/Shares/Public";
          browseable = "yes";
          public = "yes";
          "writeable" = "yes";
          "guest ok" = "yes";
          "create mask" = "0644";
          "directory mask" = "0755";
          "force user" = "titouan";
        };
        private = {
          path = "/mnt/Shares/Private";
          browseable = "yes";
          "read only" = "no";
          "guest ok" = "no";
          "create mask" = "0644";
          "directory mask" = "0755";
          # "force user" = "titouan";
        };
      };
    };
  };
}
