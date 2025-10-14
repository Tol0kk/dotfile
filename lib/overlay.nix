{
  inputs,
  self,
  ...
}:
[
  (prev: super: {
    python312 = super.python312.override {
      packageOverrides = python-final: python-prev: {
        webrtc-noise-gain = python-prev.webrtc-noise-gain.overrideDerivation (oldAttrs: {
          postPatch = with oldAttrs.stdenv.hostPlatform.uname; ''
            # Configure the correct host platform for cross builds
            substituteInPlace setup.py --replace-fail \
              "system = platform.system().lower()" \
              'system = "${prev.lib.toLower system}"'
            substituteInPlace setup.py --replace-fail \
              "machine = platform.machine().lower()" \
              'machine = "${prev.lib.toLower processor}"'
          '';
        });
      };
    };
    rkffmpeg = prev.callPackage "${self}/packages/rkffmpeg" { };
    rkmpp = prev.callPackage "${self}/packages/rkffmpeg/rkmpp.nix" { };
    nixos-plymouth-custom = prev.callPackage "${self}/packages/nixos-plymouth-custom" { };
  })
  inputs.blender-bin.overlays.default
  inputs.nix-topology.overlays.default
]
