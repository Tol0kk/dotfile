{
  lib,
  libCustom,
  inputs,
  pkgs,
  ...
}:
with lib;
with libCustom;
{
  options.modules.defaults = {
    file_manager = mkOpt (types.either types.path types.str) null "Default FileManager";
    terminal = mkOpt (types.either types.path types.str) null "Default Terminal";
    browser = mkOpt (types.either types.path types.str) null "Default Browser";
    editor = mkOpt (types.either types.path types.str) null "Default Editor";
  };

  config.modules.defaults.browser = "${
    inputs.zen-browser.packages."${pkgs.system}".beta
  }/bin/zen-beta";
}
