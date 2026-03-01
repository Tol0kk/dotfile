{
  flake.nixosModules.anrdoid-virt =
    {
      lib,
      ...
    }:
    {
      # TODO check if ok
      virtualisation.waydroid.enable = true;
      # TODO persit:
      # waydroid prop set persist.waydroid.width 2400
      # waydroid prop set persist.waydroid.height 3840
    };
}
