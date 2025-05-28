{
  pkgs,
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.apps.tools;
in {
  # TODO redo this part
  options.modules.apps.tools = {
    security.enable = mkEnableOpt "Enable Security tools";
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
      burpsuite
      volatility3
      radare2
      sniffnet
    ];
    programs.wireshark.enable = true;
  };
}
