{ inputs, ... }:
{
  flake.homeModules.noctalia =
    {
      pkgs,
      lib,
      config,
      libCustom,
      isPure,
      ...
    }:
    let
      mkSource = relPath: absPath: {
        force = true;
        source = if isPure then relPath else config.lib.file.mkOutOfStoreSymlink absPath;
      };
    in
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      stylix.targets.noctalia-shell.enable = false;
      programs.noctalia-shell = {
        enable = true;
      };

      home.file.".config/noctalia" =
        mkSource ./config "${config.dotfiles}/modules/stable/system/desktopEnvironment/common/noctalia/config"
        // {
          recursive = true;
        };
      home.sessionVariables = {
        # QT_QPA_PLATFORMTHEME = "gtk3";
      };

      home.packages = [
        pkgs.quickshell
        pkgs.gpu-screen-recorder
      ];
    };

  flake.nixosModules.noctalia =
    { ... }:
    {
      networking.networkmanager.enable = true;
      hardware.bluetooth.enable = true;
      services.tuned.enable = true;
      services.upower.enable = true;
    };
}
