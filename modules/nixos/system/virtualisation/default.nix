{
  pkgs,
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.system.virtualisation;
in {
  options.modules.system.virtualisation = {
    docker.enable = mkEnableOpt "Enable docker virtualisation";
    virtualbox.enable = mkEnableOpt "Enable VirtualBox";
    waydroid.enable = mkEnableOpt "Enable Waydroid";
    qemu = {
      enable = mkEnableOpt "Enable KVM/Qemu/Virt-manager virtualisation";
      startOnBoot = mkEnableOpt "Start libvirt vm on boot";
    };
  };

  config = mkMerge [
    (mkIf cfg.docker.enable {
      virtualisation.docker.enable = true;
      hardware.nvidia-container-toolkit.enable = true;
      virtualisation.docker.autoPrune.enable = true;
      virtualisation.docker.daemon.settings = {
        default-ulimits = {
          # Some docker image need larger limits (Java projects... :/)
          nofile = {
            Hard = 524288;
            Name = "nofile";
            Soft = 524288;
          };
        };
      };
      environment.systemPackages = with pkgs; [
        docker-compose
      ];
    })
    (mkIf cfg.virtualbox.enable {
      users.extraGroups.vboxusers.members = ["user-with-access-to-virtualbox"];
      virtualisation.virtualbox.host.enable = true;
      virtualisation.virtualbox.host.enableExtensionPack = true;
    })
    (mkIf cfg.waydroid.enable {
      # TODO check if ok
      virtualisation.waydroid.enable = true;
      # TODO persit:
      # waydroid prop set persist.waydroid.width 2400
      # waydroid prop set persist.waydroid.height 3840
    })
    (mkIf cfg.qemu.enable {
      virtualisation.libvirtd = {
        enable = true;
        qemu.swtpm.enable = true;
        onShutdown = "suspend";
        onBoot = mkIf cfg.qemu.startOnBoot "start";
      };
      programs.virt-manager.enable = true;
    })
  ];
}
