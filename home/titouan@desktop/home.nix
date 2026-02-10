{
  libCustom,
  self,
  config,
  ...
}:
with libCustom; {
  sops.secrets."titouan/syncthings_key" = {
    sopsFile = ./secrets.yaml;
  };

  sops.secrets."titouan/syncthings_cert" = {
    sopsFile = ./secrets.yaml;
  };

  modules = {
    users.titouan = enabled;
    services.syncthing = {
      enable = true;
      key = config.sops.secrets."titouan/syncthings_key".path;
      cert = config.sops.secrets."titouan/syncthings_cert".path;
    };
  };
  sops.defaultSopsFile = "${self}/home/titouan@desktop/secrets.yaml";

  services.syncthing.settings = {
    devices = {
      "laptop" = {
        id = "NA3NM5T-H7G6LML-ASUPNYP-WYRNFSL-XJW4Q67-GGOXXTV-3CEC5OY-3G2YNQU";
      };
      # "device2" = {
      #   id = "DEVICE-ID-GOES-HERE";
      # };
    };
    folders = {
      "Documents" = {
        path = "~/Documents";
        devices = ["laptop"];
      };
      "dev" = {
        path = "~/dev";
      };
      "Pictures" = {
        path = "~/Pictures";
        devices = ["laptop"];
      };
      "Videos" = {
        path = "~/Videos";
        devices = ["laptop"];
      };
      "journal" = {
        path = "~/journal";
        devices = ["laptop"];
      };
      "Music" = {
        path = "~/Music";
        devices = ["laptop"];
      };
      "Templates" = {
        path = "~/Templates";
        devices = ["laptop"];
      };
      "Games/Sync" = {
        path = "~/Games/Sync";
        devices = ["laptop"];
      };
    };
  };
}
