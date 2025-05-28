{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.services.ollama;
in {
  options.modules.services.ollama = {
    enable = mkEnableOpt "Enable Ollama";
  };

  config = mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = pkgs.ollama-cuda;
    };
  };
}
