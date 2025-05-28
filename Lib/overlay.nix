{
  inputs,
  self,
  ...
}: [
  (prev: super: {
    # gnome = super.gnome.overrideScope (selfg: superg: {
    #   gnome-shell = superg.gnome-shell.overrideAttrs (old: {
    #     patches = (old.patches or [ ]) ++ [
    #       (
    #         let
    #           bg = "${(prev.callPackage "${self}/Pkgs/assetsPkgs" {})}/background.jpg";
    #         in
    #         prev.writeText "bg.patch" ''
    #           --- a/data/theme/gnome-shell-sass/widgets/_login-lock.scss
    #           +++ b/data/theme/gnome-shell-sass/widgets/_login-lock.scss
    #           @@ -14,7 +14,9 @@ $_gdm_dialog_width: 23em;

    #            /* Login Dialog */
    #            .login-dialog {
    #           -  background-color: $_gdm_bg;
    #           +  background-color: transparent;
    #           +  background-image: url('file://${bg}');
    #           +  background-size: cover;
    #            }
    #         ''
    #       )
    #     ];
    #   });
    # });

    python312 =
      super.python312.override
      {
        packageOverrides = python-final: python-prev: {
          webrtc-noise-gain = python-prev.webrtc-noise-gain.overrideDerivation (
            oldAttrs: {
              postPatch = with oldAttrs.stdenv.hostPlatform.uname; ''
                # Configure the correct host platform for cross builds
                substituteInPlace setup.py --replace-fail \
                  "system = platform.system().lower()" \
                  'system = "${prev.lib.toLower system}"'
                substituteInPlace setup.py --replace-fail \
                  "machine = platform.machine().lower()" \
                  'machine = "${prev.lib.toLower processor}"'
              '';
            }
          );
        };
      };
    assets = prev.callPackage "${self}/Pkgs/assetsPkgs" {};
  })
  inputs.blender-bin.overlays.default
  inputs.nix-topology.overlays.default
]
