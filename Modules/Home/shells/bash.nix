{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shells.bash;
in

{
  options.modules.shells.bash = {
    enable = mkOption {
      description = "Enable bash";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.bash = {
      enable = true;
      enableVteIntegration = true;
      enableCompletion = true;
      # initExtra = ''
      #   source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      # '';
    };
  };
}
