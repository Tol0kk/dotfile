{
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.archetype.server;
in
{
  options.modules.archetype.server = {
    enable = mkEnableOpt "Enable server archetype";
  };

  # TODO replace modules/nixos/server
  config = mkIf cfg.enable {
    environment.shellInit = ''
      export TERM=xterm
    '';

    programs.command-not-found.enable = false;
    documentation.enable = false;
    documentation.nixos.enable = false;
    documentation.man.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    services.printing.enable = false; # Removes cups/ghostscript

    modules.system.ssh = {
      enable = true;
      auto-start-sshd = true;
    };

    networking.firewall = {
      enable = true;
      allowedTCPPorts = [
        22
      ];
    };
  };
}
