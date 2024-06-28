{ self, nixpkgs, ... } @ inputs: {
  # <machine-name> = self.lib.mkSystem inputs "<machine-name> pkgs "<system-arch>";"
  laptop = self.lib.mkSystem inputs {
    inherit nixpkgs;
    hostname = "laptop";
    system = "x86_64-linux";
  };
  desktop = self.lib.mkSystem inputs {
    inherit nixpkgs;
    system = "x86_64-linux";
  hostname = "desktop";
  };
}
