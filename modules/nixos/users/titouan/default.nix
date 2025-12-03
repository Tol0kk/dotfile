{
  self,
  lib,
  libCustom,
  config,
  withHomeManager,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.users.titouan;
in
{
  options.modules.users.titouan = {
    enable = mkEnableOpt "Enable Titouan Users";
    isWheel = mkEnableOpt "is Titouan Admin" // {
      default = true;
    };
    withHomeManager = mkEnableOpt "Use HomeManager Settings from Titouan" // {
      default = withHomeManager;
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      users.users.titouan = {
        isNormalUser = true;
        extraGroups = [
          "scanner"
          "lp"
          "mpd"
          "storage"
          "networkmanager"
          "wireshark"
          "docker"
          "libvirtd"
          "input"
          "adbusers"
          "gamemode"
          "dialout" # Acess to /dev/ttyUSBX
        ]
        ++ optionals cfg.isWheel [ "wheel" ];
        useDefaultShell = true;
        createHome = true;
        initialPassword = "nixos";
      };
    })
    (mkIf (cfg.enable && cfg.withHomeManager) {
      home-manager.users.titouan = import "${self}/home/titouan@${config.networking.hostName}/home.nix";
    })
  ];
}
