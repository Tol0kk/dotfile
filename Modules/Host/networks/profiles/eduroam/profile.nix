{
  connection = {
    id = "eduroam";
    type = "wifi";
  };
  wifi = {
    mode = "infrastructure";
    ssid = "eduroam";
  };
  wifi-security = {
    key-mgmt = "wpa-eap";
  };
  "802-1x" = {
    anonymous-identity = "anonymous@univ-rennes.fr";
    ca-cert = "${./univ-rennes-ca.pem}";
    eap = "peap;";
    identity = "$eduroamID";
    password = "$eduroamPSK";
    phase2-auth = "mschapv2";
  };
  ipv4 = {
    method = "auto";
  };
  ipv6 = {
    method = "auto";
    addr-gen-mode = "stable-privacy";
  };
}
