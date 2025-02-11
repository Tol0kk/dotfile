{
  pkgs,
  inputs,
  lib,
  config,
  pkgs-stable,
  ...
}:
with lib; let
  cfg = config.modules.hypr;
in {
  imports = [inputs.hyprpanel.homeManagerModules.hyprpanel];

  config = mkIf cfg.enable {
    programs.hyprpanel = {
      # Enable the module.
      # Default: false
      enable = true;
      overlay.enable = true;
      # Import a theme from './themes/*.json'.
      # Default: ""
      theme = "gruvbox_split";
      # Configure bar layouts for monitors.
      # See 'https://hyprpanel.com/configuration/panel.html'.
      # Default: null
      layout = {
        bar.layouts = {
          "0" = {
            left = ["dashboard" "workspaces" "windowtitle"];
            middle = ["media"];
            right = ["volume" "network" "bluetooth" "systray" "clock" "battery" "notifications"];
          };
          "1" = {
            left = ["dashboard" "workspaces" "windowtitle"];
            middle = ["media"];
            right = ["volume" "clock" "notifications"];
          };
        };
      };
      settings = {
        bar.battery.hideLabelWhenFull = true;
        bar.bluetooth.label = false;
        bar.bluetooth.middleClick = "blueman-manager";
        bar.clock.format = " %H:%M";
        bar.launcher.autoDetectIcon = true;
        bar.launcher.icon = "❄️";
        bar.media.show_active_only = true;
        bar.network.middleClick = "${pkgs.kitty}/bin/kitty ${pkgs.networkmanager}/bin/nmtui"; # TODO:
        bar.network.showWifiInfo = true;
        bar.network.truncation_size = 9;
        bar.notifications.show_total = true;
        bar.notifications.hideCountWhenZero = true;
        bar.volume.label = false;
        bar.volume.middleClick = "${pkgs.pavucontrol}/bin/pavucontrol";
        bar.volume.rightClick = "${pkgs.pavucontrol}/bin/pavucontrol";
        bar.workspaces.showApplicationIcons = true;
        bar.workspaces.showWsIcons = true;
        bar.workspaces.spacing = 0.5;
        menus.clock.time.military = true;
        menus.clock.weather.key = "f26639b088424d659d0195203251102"; #TODO: expose inside a json with sops secrets
        menus.clock.weather.location = "Rennes";
        menus.clock.weather.unit = "metric";
        menus.dashboard.stats.enable_gpu = true;
        terminal = "${pkgs.kitty}/bin/kitty";
        theme.bar.buttons.bluetooth.spacing = "0.6em";
        theme.font.name = "Maple Mono";
        theme.font.size = "0.8rem";
        theme.font.weight = 900;
        theme.bar.floating = true;
        theme.bar.margin_top = "0.4em";
        theme.bar.dropdownGap = "3.3em";
        theme.bar.border_radius = "0.8em";
        theme.bar.buttons.y_margins = "0.3em";
        bar.customModules.hyprsunset.label = false;
        bar.customModules.netstat.label = false;
        bar.customModules.storage.round = true;
      };
    };
  };
}
