{ stdenv, pkgs, lib, ... }:
stdenv.mkDerivation rec {
  name = "myWallpapers";
  src = builtins.fetchGit {
    url = "git@github.com:Tol0kk/wallpapers.git";
    ref = "main";
    rev = "173e36d47a1fd898145a6129f8a199527fefa6a0";
  };

  installPhase = ''
    mkdir -p $out
    cp * $out/.
  '';

  meta = with lib; {
    description = "";
    homepage = "https://github.com/Tol0kk/wallpapers";
    license = with licenses; [ mit ];
    maintainers = with maintainers; [ Tol0kk ];
  };
}


