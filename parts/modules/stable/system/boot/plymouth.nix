{
  flake.nixosModules.plymouth =
    { pkgs, ... }:
    {
      boot = {
        initrd.systemd.enable = true; # Needed for plymouth
        plymouth = {
          enable = true;
          theme = "nixos-plymouth-custom";
          # theme = "cubes";
          themePackages = with pkgs; [
            # By default we would install all themes
            (adi1090x-plymouth-themes.override {
              selected_themes = [ "cubes" ];
            })
            nixos-plymouth-custom
          ];
        };

        # Enable "Silent Boot"
        consoleLogLevel = 0;
        initrd.verbose = false;
        kernelParams = [
          "quiet"
          "splash"
          "boot.shell_on_fail"
          "loglevel=3"
          "rd.systemd.show_status=false"
          "rd.udev.log_level=3"
          "udev.log_priority=3"
        ];
      };
    };
}
