{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.dev.languages.octave;
in
{
  options.modules.dev.languages.octave = {
    enable = mkOption {
      description = "Enable octave language component";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (octaveFull.withPackages (opkgs: with opkgs; [
        symbolic
        video
        strings
        statistics
        signal
        quaternion
        linear-algebra
        image
        geometry
        financial
        arduino
      ]))
    ];
  };
}
