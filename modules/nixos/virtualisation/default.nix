{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.virtualisation;
in {
  options.modules.virtualisation = {
    docker.enable = mkOption {
      description = "Enable docker virtualisation";
      type = types.bool;
      default = false;
    };
    virtualbox.enable = mkOption {
      description = "Enable VirtualBox";
      type = types.bool;
      default = false;
    };
    waydroid.enable = mkOption {
      description = "Enable Waydroid";
      type = types.bool;
      default = false;
    };
    kvm = {
      enable = mkOption {
        description = "Enable KVM/Qemu/Virt-manager virtualisation";
        type = types.bool;
        default = false;
      };
      startOnBoot = mkOption {
        description = "Start libvirt vm on boot";
        type = types.bool;
        default = false;
      };
    };
  };

  config = mkMerge [
    (mkIf cfg.docker.enable {
      virtualisation.docker.enable = true;
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
      virtualisation.waydroid.enable = true;
      # TODO persit:
      # waydroid prop set persist.waydroid.width 2400
      # waydroid prop set persist.waydroid.height 3840
    })
    (mkIf cfg.kvm.enable {
      virtualisation.libvirtd = {
        enable = true;
        onShutdown = "suspend";
        onBoot = mkIf cfg.kvm.startOnBoot "start";
        # qemu.ovmf = {
        #   enable = true;
        #   packages = [ pkgs.OVMFFull.fd ];
        # };
        # qemu.swtpm = {
        #   package = pkgs.swtpm;
        #   enable = true;
        # };
      };
      # virtualisation.kvmgt.enable = true;
      # environment.systemPackages = with pkgs; [
      #   qemu_kvm
      #   libguestfs
      # ];
      programs.virt-manager.enable = true;
    })
  ];
}
