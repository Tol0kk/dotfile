{
  lib,
  config,
  libCustom,
  assets,
  pkgs,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.shell.fish;
in {
  options.modules.shell.fish = {
    enable = mkEnableOpt "Enable Fish shell";
    withfastfetch = mkEnableOpt "Enable fastfetch greeting" // {default = true;};
  };

  config = mkIf cfg.enable {
    modules.shell.fastfetch.enable = cfg.withfastfetch;
    programs.nix-your-shell.enable = true;

    programs.fish = {
      enable = true;
      shellAbbrs = assets.shellAliases;
      functions = {
        fish_greeting = mkIf cfg.withfastfetch "fastfetch";
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
  };
}
