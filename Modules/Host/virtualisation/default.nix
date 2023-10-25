{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.virtualisation;
in
{
  options.modules.virtualisation = {
    enable = mkOption {
      description = "Enable virtualisation";
      type = types.bool;
      default = false;
    };
    docker.enable = mkOption {
      description = "Enable virtualisation";
      type = types.bool;
      default = false;
    };
    waydroid.enable = mkOption {
      description = "Enable virtualisation";
      type = types.bool;
      default = false;
    };
    virtualbox.enable = mkOption {
      description = "Enable virtualisation";
      type = types.bool;
      default = false;
    };
    virt-manager.enable = mkOption {
      description = "Enable Virt-manager";
      type = types.bool;
      default = false;
    };
  };

  config =
    (mkMerge [
      (mkIf cfg.waydroid.enable {
        virtualisation.waydroid.enable = true;
      })
      (mkIf cfg.docker.enable {
        virtualisation.docker.enable = true;
      })
      (mkIf cfg.virtualbox.enable {
        environment.systemPackages = with pkgs; [
          virtualbox
        ];
      })
      (mkIf cfg.virt-manager.enable {
        environment.systemPackages = with pkgs; [
          virt-manager
        ];
        programs.dconf.enable = true;
        virtualisation.libvirtd.enable = true;
      })
    ]);
}
