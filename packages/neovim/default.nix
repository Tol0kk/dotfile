{
  pkgs,
  nvf ? null,
}:
let
  mkNeovim =
    {
      pkgs,
      isMinimal,
      ...
    }@args:
    (nvf.lib.neovimConfiguration {
      inherit pkgs;
      modules = [ (import ./config (args // { lib = pkgs.lib; })) ];
    }).neovim;

  tiny-neovim = mkNeovim {
    inherit pkgs;
    isMinimal = true;
  };

  neovim = mkNeovim {
    inherit pkgs;
    isMinimal = false;
  };
in
{
  inherit tiny-neovim neovim mkNeovim;
}
