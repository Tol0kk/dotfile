{
  lib,
  config,
  pkgs,
  pkgs-unstable,
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
      package = pkgs.starship;
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
        function notify_long_tasks --on-event fish_postexec
            if [ "$CMD_DURATION" -gt 20000 ] # 5 seconds
              set duration (echo "$CMD_DURATION 1000" | ${pkgs.busybox}/bin/awk '{printf "%.3fs", $1 / $2}')
              ${pkgs.libnotify}/bin/notify-send (echo (history | head -n 1) returned $status after $duration) &> /dev/null
            end
        end

        ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
      '';
    };


    programs.bash = {
      enable = true;
      enableCompletion = true;
      shellAliases = import ./aliases.nix;
      initExtra = ''
        ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
        fastfetch
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
