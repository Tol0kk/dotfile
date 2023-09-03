{ inputs, self, ... }: [
  (self: super: {
    # my-assets = super.callPackage ../../Pkgs/MyAssets/default.nix { };
    # eww-wayland = super.callPackage ../Pkgs/eww { withWayland = true; };

  })
]
