{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shells.nushell;
in

{
  options.modules.shells.nushell = {
    enable = mkOption {
      description = "Enable nushell";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.nushell = {
      enable = true;
      shellAliases = import ./aliases.nix;
    };
  };
}
