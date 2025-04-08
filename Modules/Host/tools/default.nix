{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.tools;
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
      # Web enumeration
      # Domain Info
      inetutils # (telnet, whois, ping, traceroute)
      dig.dnsutils # (dig, nslookup, nsupdate, delv)
      amass # (amass)
      # Port Info/Enumeration
      nmap # (nmap)

      openvpn
      samba
      findutils.locate
      tmux
      gobuster
      whatweb
      exploitdb
      metasploit
      binwalk
      wireshark
    ];
    programs.wireshark.enable = true;
  };
}
