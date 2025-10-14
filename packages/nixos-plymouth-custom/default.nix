{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "nixos-plymouth-custom";
  version = "0.1.0";
  src = ./src;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/nixos-plymouth-custom
    cp -r nixos-plymouth $out/share/plymouth/themes/
    chmod +x $out/share/plymouth/themes/nixos-plymouth/nixos-plymouth-custom.plymouth
    substituteInPlace $out/share/plymouth/themes/nixos-plymouth-custom/nixos-plymouth-custom.plymouth --replace '@IMAGES@' "$out/share/plymouth/themes/mac-style/images/"
  '';
}
