{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.wireshark;
in
{
  options.modules.wireshark = {
    enable = mkOption {
      description = "Enable wireshark";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.wireshark.enable = true;
  };
}
