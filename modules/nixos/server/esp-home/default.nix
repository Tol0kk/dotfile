{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.server.esp-home;
in
{
  options.modules.server.esp-home = {
    enable = mkOption {
      description = "Enable Esp Home service";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # TODO see https://search.nixos.org/options?channel=unstable&from=0&size=50&sort=relevance&type=packages&query=esphome
    services.esphome.enable = true;
  };
}
