{ inputs, ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        packages = [
          pkgs.nix-diff
          pkgs.opentofu
          pkgs.nixfmt
        ];
        shellHook = ''
          echo "========================================"
          echo "⚙️ Environment loaded!"
          echo "========================================"
        '';
      };
    };

}
