{
  lib,
  libCustom,
  config,
  assets,
  inputs,
  pkgs,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.system.stylix;
in
{
  options.modules.system.stylix = {
    enable = mkEnableOpt "Enable Stylix";
  };

  imports = [ inputs.stylix.nixosModules.stylix ];
  config = mkMerge [
    (mkIf (!cfg.enable) { stylix.autoEnable = false; })
    (mkIf cfg.enable {
      # stylix.autoEnable = false;
      stylix.enable = true;
      stylix.polarity = "dark";
      stylix.image = assets.backgrounds.background-1;
      stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-hard.yaml";

      stylix.targets.plymouth.enable = false;

      stylix.cursor = {
        package = pkgs.phinger-cursors;
        name = "phinger-cursors-light";
        size = 24;
      };
      stylix.fonts = with pkgs; {
        serif = {
          package = noto-fonts-cjk-sans;
          name = "Noto Sans CJK JP";
        };

        sansSerif = {
          package = noto-fonts-cjk-sans;
          name = "Noto Sans CJK JP";
        };

        monospace = {
          # Full version, embed with icons, Chinese and Japanese glyphs (With -NF-CN suffix)
          # Unhinted font is used for high resolution screen (e.g. for MacBook). Using "hinted font" will blur your text or make it looks weird.
          package = maple-mono.truetype;
          name = "Maple Mono";
        };

        emoji = {
          package = noto-fonts-color-emoji;
          name = "Noto Color Emoji";
        };

        # TODO
        # sizes = {
        #   applications = cfg.font-size;
        #   desktop = cfg.font-size;
        #   popups = cfg.font-size;
        #   terminal = cfg.font-size;
        # };
      };
    })
  ];
}
