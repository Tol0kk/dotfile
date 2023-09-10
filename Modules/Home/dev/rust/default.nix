{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev.languages.rust;
in
{
  options.modules.dev.languages.rust = {
    enable = mkOption {
      description = "Enable Rust language component";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      ### Hardware stuff
      itm-tools # to work with STM32 board
      cargo-binutils
    ];
  };
}
