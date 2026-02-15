{
  pkgs,
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.archetype.security;
in
{
  options.modules.archetype.security = {
    enable = mkEnableOpt "Enable security archetype";
    essenstials = mkOption {
      description = "Enable essentials tools";
      type = types.bool;
      default = true;
    };
    heavy = mkEnableOpt "Enable enable heavy tools";
  };

  config = mkMerge [
    (mkIf (cfg.enable && cfg.essenstials) {
      programs.wireshark.enable = true;
      environment.systemPackages = with pkgs; [
        seclists
        binwalk
        volatility3
        whatweb
        dig.dnsutils # (dig, nslookup, nsupdate, delv)
        amass # (amass)
        nmap # (nmap)
      ];
    })
    (mkIf (cfg.enable && cfg.heavy) {
      environment.systemPackages = with pkgs; [
        caido
        burpsuite
        metasploit
        mullvad-browser

        # Not essentials
        # Web enumeration
        # Domain Info
        inetutils # (telnet, whois, ping, traceroute)
        # Port Info/Enumeration
        openvpn
        samba
        findutils.locate
        tmux
        gobuster
        exploitdb
        radare2
        sniffnet
      ];
    })
  ];
}
