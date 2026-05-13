{
  flake.nixosModules.qemu =
    {
      lib,
      ...
    }:
    with lib;
    {
      options.modules.system.virtualisation.qemu = {
        startOnBoot = mkEnableOpt "Start libvirt vm on boot";
      };
      config = {
        virtualisation.libvirtd = {
          enable = true;
          qemu.swtpm.enable = true;
          onShutdown = "suspend";
          # onBoot = mkIf cfg.qemu.startOnBoot "start";
          # onBoot = "start";
        };
        programs.virt-manager.enable = true;
      };
    };
}
