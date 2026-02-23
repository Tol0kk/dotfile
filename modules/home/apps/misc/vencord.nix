{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.apps.misc.vencord;
in
{
  options.modules.apps.misc.vencord = {
    enable = mkEnableOpt "Enable Vencord";
  };

  config = mkIf cfg.enable {
    programs.vesktop = {
      enable = true;

      vencord.settings = {
        autoUpdate = false;
        autoUpdateNotification = false;
        notifyAboutUpdates = false;

        plugins = {
          ClearURLs.enabled = true;
          FixYoutubeEmbeds.enabled = true;
        };
      };
    };
  };
}
