{
  flake.nixosModules.limine = {
    boot.loader.limine.enable = true;
    boot.loader.limine.secureBoot.enable = false;
    boot.loader.limine.style.wallpapers = [
      # assets.backgrounds.background-1
    ];
  };
}
