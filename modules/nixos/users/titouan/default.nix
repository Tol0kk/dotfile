{
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.users.titouan;
in {
  options.modules.users.titouan = {
    enable = mkEnableOpt "Enable Titouan Users";
    isWheel = mkEnableOpt "is Titouan Admin" // {default = true;};
  };

  config = mkIf cfg.enable {
    users.users.titouan = {
      isNormalUser = true;
      extraGroups =
        [
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
        ]
        ++ optionals cfg.isWheel ["wheel"];
      useDefaultShell = true;
      createHome = true;
    };
  };
}
