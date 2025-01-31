{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.fonts;
  # SF-Mono = pkgs.callPackage ../../pkgs/apple-fonts {};
in
{
  options.modules.fonts = {
    enable = mkOption {
      description = "Enable fonts";
      type = types.bool;
      default = false;
    };
  };


  config = mkIf cfg.enable {
    fonts = {
      packages = with pkgs; [
        # powerline-fonts
        # carlito
        # vegur
        # noto-fonts
        # source-code-pro
        # coresfonts
        font-awesome
        # font-awesome_5
        # line-awesome
        # SF-Mono
        cascadia-code
        # twitter-color-emoji
        # emacs-all-the-icons-fonts
        # creep
        nerd-fonts.cousine
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.dejavu-sans-mono
        nerd-fonts.jetbrains-mono
        nerd-fonts.inconsolata
      ];
      fontconfig.defaultFonts = {
        monospace = [ "JetBrainsMono" "font-awesome" ];
        sansSerif = [ "JetBrainsMono" ];
        serif = [ "JetBrainsMono" ];
      };
    };
  };
}
