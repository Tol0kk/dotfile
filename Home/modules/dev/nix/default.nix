{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev.languages.nix;
in
{
  options.modules.dev.languages.nix = {
    enable = mkOption {
      description = "Enable nix language component";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    modules.direnv.enable = true;
    home.packages = with pkgs; [
      nixpkgs-fmt
    ];
  };
}
