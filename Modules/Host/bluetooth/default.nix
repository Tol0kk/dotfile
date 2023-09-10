{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.bluetooth;
in
{
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
        };
      };
    };
    services.blueman.enable = true;
    hardware.pulseaudio = {
      package = pkgs.pulseaudioFull;
    };
  };
}
