{ self, pkgs, lib, config, ... }:
with lib;
let 
cfg = config.modules.wpaperd;
# myWallpapers = pkgs.callPackage "${self}/Pkgs/myWallpapers" {};
myWallpapers = "";

in {
  options.modules.wpaperd = {
    enable = mkOption {
      description = "Enable wpaperd";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.wpaperd ];
    xdg.configFile."wpaperd/wallpaper.toml".text = ''
      [default]
      # path = "${myWallpapers}"
      path = "/home/titouan/Pictures/Wallpapers/"
      duration = "30m"
      sorting = "ascending"
    '';
  };
  # TODO use Assets pkgs for wallpaperd dir inside zoxide config
}
