{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.neovim;

in {
  options.modules.neovim = {
    enable = mkOption {
      description = "Enable neovim";
      type = types.bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;
    };
  };
}
