{
  flake.nixosModules.hypr =
    {
      lib,
      config,
      pkgs,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    {
      config = {
        # Enable touchpad support (enabled default in most desktopManager).
        services.libinput.enable = true;

        # This set other option for hyprland, like polkit, portal, dconf, ect...
        programs.hyprland.enable = true;

        environment.systemPackages = with pkgs; [
          hyprpolkitagent
          rose-pine-hyprcursor
        ];

        programs.hyprlock.enable = true;

        qt = {
          enable = true;
          platformTheme = "qt5ct";
        };

        security.polkit.enable = true;

        xdg.portal = {
          xdgOpenUsePortal = true;
          wlr.enable = true;
          enable = true;
          extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
            xdg-desktop-portal-hyprland
          ];
          config.common.default = "*";
          config = {
          };
        };
      };
    };
}
