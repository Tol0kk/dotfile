{
  lib,
  config,
  libCustom,
  inputs,
  pkgs,
  isPure,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.desktop.wayland.vicinae;
  jsonFormat = pkgs.formats.json { };

  mkSource =
    relPath: absPath: if isPure then relPath else config.lib.file.mkOutOfStoreSymlink absPath;
in
{
  options.modules.desktop.wayland.vicinae = {
    enable = mkEnableOpt "Enable vicinae";
  };

  # TODO Clean UP
  config = mkIf cfg.enable {
    stylix.targets.vicinae.enable = true;
    services.vicinae = {
      enable = true;
      package = pkgs.vicinae;
      systemd = {
        enable = true;
        autoStart = true; # default: false
        environment = {
          USE_LAYER_SHELL = 1;
        };
      };
      settings = {
        # close_on_focus_loss = true;
        # consider_preedit = true;
        # pop_to_root_on_close = true;
        # favicon_service = "twenty";
        # search_files_in_root = true;
        # font = {
        #   normal = {
        #     size = 12;
        #     family = "Maple Nerd Font";
        #   };
        # };
        # theme = {
        #   light = {
        #     name = "vicinae-light";
        #     icon_theme = "default";
        #   };
        #   dark = {
        #     name = "vicinae-dark";
        #     icon_theme = "default";
        #   };
        # };
        # launcher_window = {
        #   opacity = mkForce 0.95;
        # };
      };
      extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
        bluetooth
        nix
        power-profile
        searxng
        stocks
      ];
    };

    home.file.".config/vicinae/settings.json".source =
      mkSource ./settings.json "${config.dotfiles}/modules/home/desktop/wayland/vicinae/settings.json";

    xdg.configFile = {
      "vicinae/settingsro.json" = lib.mkIf (config.services.vicinae.settings != { }) {
        source = jsonFormat.generate "vicinae-settings" config.services.vicinae.settings;
      };
      "vicinae/settings.json".enable = false;
    };
  };
}
