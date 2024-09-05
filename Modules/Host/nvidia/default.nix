{ lib, config, ... }:
with lib;
let
  cfg = config.modules.nvidia;
in
{
  options.modules.nvidia = {
    enable = mkOption {
      description = "Enable nvidia";
       type = types.bool;
      default = false;
    };
    offload.enable = mkOption {
      description = "Enable nvidia PRIME offload";
      type = types.bool;
      default = false;
    };
    offload.intelBusId = mkOption {
      description = "Bus ID of the Intel GPU. You can find it using lspci; for example if lspci shows the Intel GPU at “00:02.0”, set this option to “PCI:0:2:0”.";
      type = types.str;
      default = "";
    };
    offload.nvidiaBusId = mkOption {
      description = "Bus ID of the NVIDIA GPU. You can find it using lspci; for example if lspci shows the NVIDIA GPU at “01:00.0”, set this option to “PCI:1:0:0”.";
      type = types.str;
      default = "";
    };
    PowerManagement.enable = mkOption {
      description = "Enable nvidia PowerManagement";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement.enable = cfg.PowerManagement.enable;
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };
    services.xserver.videoDrivers = [ "nvidia" ];
    hardware.nvidia.prime = mkIf cfg.offload.enable {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = cfg.offload.intelBusId;
      nvidiaBusId = cfg.offload.nvidiaBusId;
    };
  };
}
