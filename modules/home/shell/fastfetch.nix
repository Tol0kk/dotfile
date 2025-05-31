{
  lib,
  config,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.shell.fastfetch;
in {
  options.modules.shell.fastfetch = {
    enable = mkEnableOpt "Enable Fastfetch";
  };

  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      settings = {
        logo = {
          source = "nixos_small";
          padding = {
            right = 1;
          };
        };
        display = {
          size.binaryPrefix = "si";
          color = "blue";
          separator = "  ";
        };
        modules = [
          {
            type = "datetime";
            key = "Date";
            format = "{11}/{3}/{1}";
          }
          {
            type = "datetime";
            key = "Time";
            format = "{14}:{17}";
          }
          "uptime"
          "packages"
          "shell"
          "cpu"
          "memory"
        ];
      };
    };
  };
}
