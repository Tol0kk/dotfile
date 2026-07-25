{
  flake.nixosModules.qemu =
    {
      lib,
      config,
      ...
    }:
    let
      cfg = config.modules.system.virtualisation.qemu;
    in
    {
      key = "nixosModules.qemu";
      options.modules.system.virtualisation.qemu.startOnBoot =
        lib.mkEnableOption "Start libvirt VMs on boot";

      config.virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
        onShutdown = "suspend";
        onBoot = if cfg.startOnBoot then "start" else "ignore";
      };
      config.programs.virt-manager.enable = true;
    };
}
