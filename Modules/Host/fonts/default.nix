{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.fonts;
  # SF-Mono = pkgs.callPackage ../../pkgs/apple-fonts {};
in
{
  options.modules.fonts = {
    enable = mkOption {
      description = "Enable wayland";
      type = types.bool;
      default = true;
    };
  };


  config = mkIf cfg.enable {
    fonts = {
      # fontDir.enable = true;
      # enableDefaultPackages = true;
      # fontconfig.enable = true;
      # enableGhostscriptFonts = true;
      packages = with pkgs; [
      # packages = with pkgs; [
        powerline-fonts
        # carlito
        vegur
        noto-fonts
        source-code-pro
        # corefonts
        font-awesome
        font-awesome_5
        line-awesome
        # SF-Mono
        cascadia-code
        twitter-color-emoji
        emacs-all-the-icons-fonts
        creep
        (nerdfonts.override {
          fonts = [
            "Cousine"
            "FiraCode"
            "Hasklig"
            "DroidSansMono"
            "DejaVuSansMono"
            "iA-Writer"
            "JetBrainsMono"
            "Meslo"
            "SourceCodePro"
            "Inconsolata"
          ];
        })
      ];
      fontconfig.defaultFonts = {
        monospace = [ "JetBrainsMono" "font-awesome" ];
        sansSerif = [ "JetBrainsMono" ];
        serif = [ "JetBrainsMono" ];
      };
    };
  };
}
