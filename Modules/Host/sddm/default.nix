{ pkgs, lib, config, self, inputs, ... }:

with lib;
let
  cfg = config.modules.sddm;
in
{
  options.modules.sddm = {
    enable = mkOption {
      description = "Enable Sddm";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      (callPackage "${self}/Pkgs/sddm-chili" { username = "titouan"; }) # for sddm
    ];

    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.displayManager.sddm.theme = "${self}/Pkgs/sddm-chili";
    services.xserver.displayManager.defaultSession = "hyprland";
    services.xserver.displayManager.sessionPackages = [
      (inputs.hyprland.packages.${pkgs.system}.hyprland.override
        {
          enableXWayland = true;
          enableNvidiaPatches = true;
        })
    ];

  };
}
