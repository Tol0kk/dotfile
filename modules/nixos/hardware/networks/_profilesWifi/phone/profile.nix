{
  connection = {
    id = "Partage";
    type = "wifi";
  };
  wifi = {
    ssid = "$phoneSSID";
  };
  wifi-security = {
    key-mgmt = "wpa-psk";
    psk = "$phonePSK";
  };
}
