{
  flake.nixosModules.qemu =
    {
      lib,
      ...
    }:
    with lib;
    let
      cfg = config.modules.system.virtualisation;
    in
    {
      options.modules.system.virtualisation.qemu = {
        startOnBoot = mkEnableOpt "Start libvirt vm on boot";
      };
      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
        onShutdown = "suspend";
        onBoot = mkIf cfg.qemu.startOnBoot "start";
      };
      programs.virt-manager.enable = true;
    };
}
