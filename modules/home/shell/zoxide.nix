{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.shell.zoxide;
in
{
  options.modules.shell.zoxide = {
    enable = mkEnableOpt "Enable Zoxide";
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
