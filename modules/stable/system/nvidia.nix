{
  flake.nixosModules.nvidia =
    {
      lib,
      libCustom,
      config,
      ...
    }:
    with lib;
    with libCustom;
    let
      cfg = config.modules.hardware.nvidia;
    in
    {
      options.modules.hardware.nvidia = {
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
        powerManagement.enable = mkEnableOpt "Enable nvidia PowerManagement";
      };

      config = {
        services.xserver.videoDrivers = [ "nvidia" ];
        hardware.graphics.enable = true;
        hardware.nvidia = {
          modesetting.enable = true; # Mandatory for wayland
          nvidiaSettings = true;
          powerManagement.enable = cfg.powerManagement.enable;
        };
        hardware.nvidia.prime = mkIf cfg.offload.enable {
          offload.enable = true;
          offload.enableOffloadCmd = true;
          intelBusId = cfg.offload.intelBusId;
          nvidiaBusId = cfg.offload.nvidiaBusId;
        };
        services.supergfxd = {
          enable = true;
          settings = {
            always_reboot = true;
          };
        };
      };
    };
}
