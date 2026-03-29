{ inputs, ... }:
{
  flake.homeModules.vicinae =
    {
      lib,
      config,
      libCustom,
      pkgs,
      isPure,
      ...
    }:
    let
      mkSource = relPath: absPath: {
        force = true;
        source = if isPure then relPath else config.lib.file.mkOutOfStoreSymlink absPath;
      };
      jsonFormat = pkgs.formats.json { };
    in
    {
      imports = [
        # inputs.vicinae.homeManagerModules.default
      ];

      # TODO Clean UP
      stylix.targets.vicinae.enable = true;
      programs.vicinae = {
        enable = true;
        package = pkgs.vicinae;
        systemd = {
          enable = true;
          autoStart = true; # default: false
          # environment = {
          #   USE_LAYER_SHELL = 1;
          # };
        };
        # extensions = with inputs.vicinae-extensions.packages.${pkgs.stdenv.hostPlatform.system}; [
        #   # bluetooth
        #   nix
        #   power-profile
        #   searxng
        #   stocks
        # ];
      };

      home.file.".config/vicinae/settings.json" =
        mkSource ./settings.json "${config.dotfiles}/modules/stable/system/desktopEnvironment/common/vicinae/settings.json";

      xdg.configFile = {
        "vicinae/settingsro.json" = lib.mkIf (config.programs.vicinae.settings != { }) {
          source = jsonFormat.generate "vicinae-settings" config.programs.vicinae.settings;
        };
        "vicinae/settings.json".enable = false;
      };
    };
}
