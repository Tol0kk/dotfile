{
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.hardware.nvidia;
in {
  options.modules.hardware.nvidia = {
    enable = mkEnableOpt "Enable nvidia";
    offload.enable = mkEnableOpt "Enable nvidia PRIME offload";
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
    PowerManagement.enable = mkEnableOpt "Enable nvidia PowerManagement";
  };

  config = mkIf cfg.enable {
    hardware.nvidia = {
      modesetting.enable = true;
      nvidiaSettings = true;
      powerManagement.enable = cfg.PowerManagement.enable;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
      open = false;
    };
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia.prime = mkIf cfg.offload.enable {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = cfg.offload.intelBusId;
      nvidiaBusId = cfg.offload.nvidiaBusId;
    };
  };
}
