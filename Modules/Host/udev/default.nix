{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.udev;
in
{
  options.modules.udev = {
    STM32DISCOVERY.enable = mkOption {
      description = "Enable STM32DISCOVERY Board ";
      type = types.bool;
      default = false;
    };
    ArduinoMega.enable = mkOption {
      description = "Enable ArduinoMega Board ";
      type = types.bool;
      default = false;
    };
  };

  config = {
    services.udev.enable = true;
    services.udev.packages = [
      (mkIf cfg.STM32DISCOVERY.enable (pkgs.writeTextFile {
        name = "openocd";
        text = ''
          # STM32F3DISCOVERY - ST-LINK/V2.1
          ATTRS{idVendor}=="0483", ATTRS{idProduct}=="374b", MODE:="0666"
        '';
        destination = "/etc/udev/rules.d/99-openocd.rules";
      }))
      (mkIf cfg.ArduinoMega.enable (pkgs.writeTextFile {
        name = "arduino";
        text = ''
          # MEGA ARDUINO 3Dprinter
          ATTRS{idVendor}=="2341", ATTRS{idProduct}=="0042", MODE:="0666"
        '';
        destination = "/etc/udev/rules.d/99-arduino-udev.rules";
      }))

    ];
  };
}
