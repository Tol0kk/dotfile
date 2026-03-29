{
  flake.homeModules.signal =
    {
      lib,
      pkgs,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    {
      home.packages = with pkgs; [
        signal-desktop
        (makeAutostartItem {
          name = "signal";
          package = signal-desktop;
          prependExtraArgs = [ "--start-in-tray" ];
        })
      ];
    };
}
