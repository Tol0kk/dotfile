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
  options.modules.shell.bash = {
    enable = mkEnableOpt "Enable Bash";
    withfastfetch = mkEnableOpt "Enable bash greeting" // {
      default = true;
    };
  };

  config = mkIf cfg.enable {
    modules.shell.fastfetch.enable = cfg.withfastfetch;
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
