{
  flake.homeModules.elements =
    {
      lib,
      pkgs,
      config,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    {
      home.packages = with pkgs; [
        element-desktop
        (makeAutostartItem {
          name = "element-desktop";
          package = element-desktop;
          prependExtraArgs = [ "--start-in-tray" ];
        })
      ];
    };
}
