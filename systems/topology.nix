{config, ...}: let
  inherit (config.lib.topology) mkRouter mkConnection mkInternet;
in {
  networks.home = {
    name = "Home Network";
    cidrv4 = "192.168.1.0/24";
  };

  nodes.router = mkRouter "Le Palace" {
    info = "ISP Router";
    # eth1-4 are switched, wan1 is the external DSL connection
    interfaceGroups = [["eth1" "eth2" "eth3" "eth4" "wifi1" "wifi2"] ["wan1"]];
    # connections.wan1 = mkConnection "desktop" "wan";
    connections.eth1 = mkConnection "olympus" "enP4p1s0";
    connections.eth2 = mkConnection "desktop" "enp25s0";
    connections.wifi1 = mkConnection "desktop" "wlp30s0";
    connections.wifi2 = mkConnection "laptop" "wlp30s0";
    # connections.eth2 = mkConnection "olympus" "eth0";
  };
  nodes.internet = mkInternet {
    connections = mkConnection "router" "wan1";
  };
}
