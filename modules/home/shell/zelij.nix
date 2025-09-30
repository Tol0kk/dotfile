{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.shell.zellij;
in {
  options.modules.shell.zellij = {
    enable = mkEnableOpt "Enable zellij";
  };

  config = mkIf cfg.enable {
    programs.zellij = {
      enable = true;
      enableFishIntegration = false;
      enableBashIntegration = false;
      enableZshIntegration = false;
      settings = {
        # TODO: see more https://zellij.dev/documentation
        # Settings like yaml
      };
    };
  };
}
