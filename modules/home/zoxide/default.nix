{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.zoxide;
in {
  options.modules.zoxide = {
    enable = mkOption {
      description = "Enable Zoxide";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
    };
  };
}
