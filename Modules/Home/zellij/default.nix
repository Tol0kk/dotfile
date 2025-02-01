{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.zellij;
in {
  options.modules.zellij = {
    enable = mkOption {
      description = "Enable zellij";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      settings = {
        # TODO: see more https://zellij.dev/documentation
        # Settings like yaml
      };
    };
  };
}
