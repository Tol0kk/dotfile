{
  libCustom,
  username,
  self,
  config,
  ...
}:
with libCustom;
{
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
      # "device1" = {
      #   id = "DEVICE-ID-GOES-HERE";
      # };
      # "device2" = {
      #   id = "DEVICE-ID-GOES-HERE";
      # };
    };
    folders = {
      "Documents" = {
        path = "~/Documents";
      };
      "dev" = {
        path = "~/dev";
      };
      "Pictures" = {
        path = "~/Pictures";
      };
      "config" = {
        path = "~/.config";
      };
      "Video" = {
        path = "~/Video";
      };
      "journal" = {
        path = "~/journal";
      };
      "Music" = {
        path = "~/Music";
      };
      "Templates" = {
        path = "~/Templates";
      };
      "Game/Sync" = {
        path = "~/Game/Sync";
      };
    };
  };
}
