{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, gtk3
, gdk-pixbuf
, withWayland ? false
, gtk-layer-shell
, stdenv
}:

rustPlatform.buildRustPackage rec {
  pname = "eww";
  version = "master";

  src = fetchFromGitHub {
    owner = "elkowar";
    repo = pname;
    rev = "0b0715fd505200db5954432b8a27ed57e3e6a72a";
    # rev = "a9a35c1804d72ef92e04ee71555bd9e5a08fa17e";
    sha256 = "sha256-GEysmNDm+olt1WXHzRwb4ZLifkXmeP5+APAN3b81/Og=";
  };

  cargoSha256 = "sha256-ILo5v3YRuy4hkxvAROPgFIAB1ur/YnfJsb5MoQ7u2QY=";



  nativeBuildInputs = [ pkg-config ];

  buildInputs = [ gtk3 gdk-pixbuf ] ++ lib.optional withWayland gtk-layer-shell;

  buildNoDefaultFeatures = withWayland;
  buildFeatures = lib.optional withWayland "wayland";

  cargoBuildFlags = [ "--bin" "eww" ];

  cargoTestFlags = cargoBuildFlags;

  # requires unstable rust features
  RUSTC_BOOTSTRAP = true;

  meta = with lib; {
    description = "ElKowars wacky widgets";
    homepage = "https://github.com/elkowar/eww";
    license = licenses.mit;
    maintainers = with maintainers; [ figsoda lom ];
    broken = stdenv.isDarwin;
  };
}