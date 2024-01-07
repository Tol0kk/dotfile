{ inputs, self, ... }: [
  (prev: super: {
    gnome = super.gnome.overrideScope' (selfg: superg: {
      gnome-shell = superg.gnome-shell.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (
            let
              bg = "${(prev.callPackage "${self}/Pkgs/assetsPkgs" {})}/background.jpg";
            in
            prev.writeText "bg.patch" ''
              --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
              +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
              @@ -14,7 +14,9 @@ $_gdm_dialog_width: 23em;

               /* Login Dialog */
               .login-dialog {
              -  background-color: $_gdm_bg;
              +  background-color: transparent;
              +  background-image: url('file://${bg}');
              +  background-size: cover;
               }
            ''
          )
        ];
      });
    });
    assets = prev.callPackage "${self}/Pkgs/assetsPkgs" { };
    color = import ./color.nix { lib = prev.lib; };
  })
  inputs.blender-bin.overlays.default
]
