{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.modules.shell;
in {
  options.modules.shell = {
    enable = mkOption {
      description = "Enable shells";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      enableTransience = true;
      settings = {
        add_newline = false;
      };
    };

    programs.fish = {
      enable = true;
      shellAbbrs = import ./aliases.nix;
      functions = {
        fish_greeting = "fastfetch";
      };
      interactiveShellInit = ''
        ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
      '';
    };

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
