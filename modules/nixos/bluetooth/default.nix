{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.bluetooth;
in {
  options.modules.bluetooth = {
    enable = mkOption {
      description = "Enable bluetooth";
      type = types.bool;
      default = false;
    };
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
