{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "nixos-plymouth-custom";
  version = "0.1.1";
  src = ./src;

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/nixos-plymouth-custom
    cp -r nixos-plymouth-custom $out/share/plymouth/themes/
    chmod +x $out/share/plymouth/themes/nixos-plymouth-custom/nixos-plymouth-custom.plymouth
    substituteInPlace $out/share/plymouth/themes/nixos-plymouth-custom/nixos-plymouth-custom.plymouth --replace '@IMAGES@' "$out/share/plymouth/themes/nixos-plymouth-custom/images/"
  '';
}
