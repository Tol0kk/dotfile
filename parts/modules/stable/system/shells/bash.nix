{ self, ... }:
{
  flake.homeModules.bash =
    {
      lib,
      config,
      libCustom,
      assets,
      pkgs,
      ...
    }:
    with lib;
    with libCustom;
    let
      cfg = config.modules.shell.bash;
    in
    {
      imports = [
        self.homeModules.fastfetch
        self.homeModules.starship
        self.homeModules.xodide
      ];

      options.modules.shell.bash = {
        withfastfetch = mkEnableOpt "Enable bash greeting" // {
          default = true;
        };
      };

      programs.nix-your-shell.enable = true;

      programs.bash = {
        enable = true;
        enableCompletion = true;
        shellAliases = assets.shellAliases;
        initExtra = ''
          ${pkgs.nix-your-shell}/bin/nix-your-shell fish | source
          ${if cfg.withfastfetch then "fastfetch" else ""}
        '';
      };
    };
}
