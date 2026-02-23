{
  pkgs-stable,
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.services.ollama;
in
{
  options.modules.services.ollama = {
    enable = mkEnableOpt "Enable Ollama";
  };

  config = mkIf cfg.enable {
    services.open-webui.enable = true;
    services.open-webui.package = pkgs-stable.open-webui;
    services.ollama = {
      enable = true;
      acceleration = mkIf config.hardware.nvidia.enabled "cuda";
    };
  };
}
