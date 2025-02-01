{
  self,
  nixpkgs-stable,
  nixpkgs-unstable,
  ...
} @ inputs: {
  # <machine-name> = self.lib.mkSystem inputs "<machine-name> pkgs "<system-arch>";"
  laptop = self.lib.mkSystem inputs {
    nixpkgs = nixpkgs-unstable;
    hostname = "laptop";
    system = "x86_64-linux";
    main_username = "titouan";
  };
  desktop = self.lib.mkSystem inputs {
    nixpkgs = nixpkgs-unstable;
    system = "x86_64-linux";
    hostname = "desktop";
    main_username = "titouan";
  };
  servrock = self.lib.mkSystem inputs {
    nixpkgs = nixpkgs-stable;
    system = "x86_64-linux";
    hostname = "servrock";
    main_username = "odin";
  };
}
