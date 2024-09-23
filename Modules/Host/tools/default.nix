{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.tools;

in {
  options.modules.tools = {
    security.enable = mkOption {
      description = "Enable Security tools";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.security.enable {
    environment.systemPackages = with pkgs; [
      openvpn
      nmap
      samba
      findutils.locate
      inetutils
      tmux
      gobuster
      whatweb
      exploitdb
      metasploit
    ];
    programs.wireshark.enable = true;
  };
}
