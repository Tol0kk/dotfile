{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.shells.zsh;
in

{
  options.modules.shells.zsh = {
    enable = mkOption {
      description = "Enable zsh";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableAutosuggestions = true;
      enableCompletion = true;
      # syntaxHighlighting.enable = true;
      enableVteIntegration = true;
      autocd = true;
      dotDir = ".config/zsh";
      # initExtra = ''
      #   source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      # '';
    };
  };
}
