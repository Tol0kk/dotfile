{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.swaync;

in {
  options.modules.swaync = {
    enable = mkOption {
      description = "Enable Sway notification center";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.swaynotificationcenter pkgs.at-spi2-core pkgs.libnotify ]; # Dependency
    systemd.user.services."swaync" = {
      Unit = {
        Description = "Swaync notification daemon";
        Documentation = "https://github.com/ErikReider/SwayNotificationCenter";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session-pre.target" ];
        ConditionEnvironment = "WAYLAND_DISPLAY";
        # X-Restart-Triggers = [
        #   "${config.xdg.configFile."swaync/config.json".source}"
        #   "${config.xdg.configFile."swaync/style.css".source}"
        # ];
      };
      Service = {
        Type = "dbus";
        BusName = "org.freedesktop.Notifications";
        ExecStart = "${pkgs.swaynotificationcenter}/bin/swaync";
        ExecReload = [ "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-config" "${pkgs.swaynotificationcenter}/bin/swaync-client --reload-css" ];
        Restart = "on-failure";
      };
      # Install.WantedBy = "graphical-session.target";
    };
  };
}
