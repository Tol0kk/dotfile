{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
  cfg = config.modules.neovim;
in {
  options.modules.neovim = {
    enable = mkOption {
      description = "Enable nvim";
      type = types.bool;
      default = true;
    };
    custom.enable = mkOption {
      description = "Enable custom Neovim config";
      type = types.bool;
      default = true;
    };
    custom.minimal = mkOption {
      description = "Make the custom Neovim config minimal";
      type = types.bool;
      default = true;
    };
  };

  imports = [inputs.nvf.nixosModules.default];
  config = mkIf cfg.enable {
    programs.nvf = {
      enable = cfg.custom.enable;
      enableManpages = cfg.custom.enable;
      settings = (import ../../../neovim {isMinimal = cfg.custom.minimal;}).config;
    };

    environment.systemPackages =
      mkIf (!cfg.custom.enable)
      [pkgs.neovim];
  };
}
