{ self, nixpkgs, ... } @ inputs: {
  # <machine-name> = self.lib.mkSystem inputs "<machine-name> pkgs "<system-arch>";"
  laptop = self.lib.mkSystem inputs "laptop" nixpkgs "x86_64-linux";
  desktop = self.lib.mkSystem inputs "desktop" nixpkgs "x86_64-linux";
}