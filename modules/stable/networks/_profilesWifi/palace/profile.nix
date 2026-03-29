{
  connection = {
    id = "Le Palace";
    type = "wifi";
  };
  wifi = {
    ssid = "$palaceSSID";
  };
  wifi-security = {
    key-mgmt = "wpa-psk";
    psk = "$palacePSK";
  };
}
