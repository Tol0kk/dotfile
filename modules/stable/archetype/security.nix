{
  flake.nixosModules.securitystation-essenstials =
    { pkgs, ... }:
    {
      programs.wireshark.enable = true;
      environment.systemPackages = with pkgs; [
        seclists
        binwalk
        volatility3
        whatweb
        dig.dnsutils # (dig, nslookup, nsupdate, delv)
        amass # (amass)
        nmap # (nmap)
        payloadsallthethings
      ];
    };

  flake.nixosModules.securitystation-heavy =
    { pkgs, ... }:
    {
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
    };
}
