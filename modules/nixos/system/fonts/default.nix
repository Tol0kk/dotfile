{
  pkgs,
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.system.fonts;
in {
  options.modules.system.fonts = {
    enable = mkEnableOpt "Enable fonts";
  };

  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        font-awesome
        cascadia-code
        nerd-fonts.cousine
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.dejavu-sans-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.inconsolata
        maple-mono.truetype
        noto-fonts-cjk-sans
      ];
      fontconfig.defaultFonts = {
        monospace = ["JetBrainsMono" "font-awesome"];
        sansSerif = ["JetBrainsMono"];
        serif = ["JetBrainsMono"];
      };
    };
  };
}
