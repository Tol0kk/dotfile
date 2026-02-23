{
  pkgs,
  lib,
  libCustom,
  config,
  inputs,
  self,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.apps.neovim;
in
{
  options.modules.apps.neovim = {
    enable = mkEnableOpt "Enable nvim";
    custom.enable = mkEnableOpt "Enable custom Neovim config";
    custom.minimal = mkEnableOpt "Make the custom Neovim config minimal" // {
      default = true;
    };
  };

  imports = [ inputs.nvf.nixosModules.default ];
  config = mkIf cfg.enable {
    programs.nvf = {
      enable = cfg.custom.enable;
      enableManpages = cfg.custom.enable;
      settings =
        (import "${self}/packages/neovim/config" {
          inherit lib;
          isMinimal = cfg.custom.minimal;
        }).config;
    };

    environment.systemPackages = mkIf (!cfg.custom.enable) [ pkgs.neovim ];
  };
}
