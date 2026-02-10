{
  libCustom,
  username,
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
  sops.defaultSopsFile = "${self}/home/titouan@laptop/secrets.yaml";

  services.syncthing.settings = {
    devices = {
      "desktop" = {
        id = "Z2AZUHX-JTHSCXG-FDVIMEB-RAAU7UR-3LQOFHO-5F4ZBJF-56G5HMN-X525BQJ";
      };
      # "device2" = {
      #   id = "DEVICE-ID-GOES-HERE";
      # };
    };
    folders = {
      "Documents" = {
        path = "~/Documents";
        devices = ["desktop"];
      };
      "dev" = {
        path = "~/dev";
      };
      "Pictures" = {
        path = "~/Pictures";
        devices = ["desktop"];
      };
      "Videos" = {
        path = "~/Videos";
        devices = ["desktop"];
      };
      "journal" = {
        path = "~/journal";
        devices = ["desktop"];
      };
      "Music" = {
        path = "~/Music";
        devices = ["desktop"];
      };
      "Templates" = {
        path = "~/Templates";
        devices = ["desktop"];
      };
      "Games/Sync" = {
        path = "~/Games/Sync";
        devices = ["desktop"];
      };
    };
  };
}
