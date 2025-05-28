{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.hardware.bluetooth;
in {
  options.modules.hardware.bluetooth = {
    enable = mkEnableOpt "Enable bluetooth";
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          experimental = true; # show battery
          Privacy = "device";
          JustWorksRepairing = "always";
          Class = "0x000100";
          FastConnectable = true;
        };
      };
    };
    services.blueman.enable = true;
    # Xbox Controller
    hardware.xpadneo.enable = true;
    hardware.xone.enable = true;
    boot = {
      extraModulePackages = with config.boot.kernelPackages; [xpadneo];
      extraModprobeConfig = ''
        options bluetooth disable_ertm=0
      '';
    };
  };
}
