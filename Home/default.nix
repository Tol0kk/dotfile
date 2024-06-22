{ self, nixpkgs, ... } @inputs:
{
  # "<username>@<machine-name> = self.libmkHome inputs "<username>" pkgs "<machine-systems>""
  "titouan@laptop" = self.lib.mkHome inputs "titouan" nixpkgs "x86_64-linux";
  "titouan" = self.lib.mkHome inputs "titouan" nixpkgs "x86_64-linux";
  "titouan@desktop" = self.lib.mkHome inputs "titouan" nixpkgs "x86_64-linux";
}