{
  flake.homeModules.vicinae =
    {
      lib,
      config,
      libCustom,
      inputs,
      pkgs,
      isPure,
      ...
    }:
    let
      inherit (libCustom) mkSource;
      jsonFormat = pkgs.formats.json { };
    in
    {
      # TODO Clean UP
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
        extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
          bluetooth
          nix
          power-profile
          searxng
          stocks
        ];
      };

      home.file.".config/vicinae/settings.json".source =
        mkSource isPure ./settings.json
          "${config.dotfiles}/modules/home/desktop/wayland/vicinae/settings.json";

      xdg.configFile = {
        "vicinae/settingsro.json" = lib.mkIf (config.services.vicinae.settings != { }) {
          source = jsonFormat.generate "vicinae-settings" config.services.vicinae.settings;
        };
        "vicinae/settings.json".enable = false;
      };
    };
}
