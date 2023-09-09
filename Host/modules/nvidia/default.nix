{ pkgs, lib, config, ... }:

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
  };

  config = mkIf cfg.enable {
    hardware.opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
    };
 

    hardware.nvidia.prime = mkIf cfg.offload.enable {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # hardware.opengl = {
    #   enable = true;
    #   driSupport = true;
    #   driSupport32Bit = true;
    #   extraPackages = with pkgs; [
    #     vaapiVdpau
    #   ];
    # };
    # boot.kernelParams = lib.mkDefault [ "acpi_rev_override" ];
  };
}
