{ pkgs, lib, config, inputs, self, ... }:

with lib;
let
  cfg = config.modules.anyrun;
in
{
  options.modules.anyrun = {
    enable = mkOption {
      description = "Enable anyrun";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      xdg-utils
    ];
    programs.anyrun = {
      enable = true;
      config = {
        plugins = [
          # An array of all the plugins you want, which either can be paths to the .so files, or their packages
          inputs.anyrun.packages.${pkgs.system}.applications
          inputs.anyrun.packages.${pkgs.system}.rink
          inputs.anyrun.packages.${pkgs.system}.symbols
          inputs.anyrun.packages.${pkgs.system}.translate
          inputs.anyrun.packages.${pkgs.system}.shell
          inputs.anyrun.packages.${pkgs.system}.dictionary
          inputs.anyrun.packages.${pkgs.system}.websearch
        ];
        x = { fraction = 0.5; };
        y = { fraction = 0.4; };
        width = { fraction = 0.3; };
        # height = { fraction = 0.2; };
        hideIcons = false;
        ignoreExclusiveZones = false;
        layer = "overlay";
        hidePluginInfo = false;
        closeOnClick = true;
        showResultsImmediately = true;
        maxEntries = 5;
      };
      extraCss = null;
      # extraCss = ''
      #   .window {
      #     background: red;
      #   }
      # '';


      # Application plugin configuration
      extraConfigFiles."applications.ron".text = ''
        Config(
          desktop_actions: false,
          max_entries: 5, 
          terminal: Some("kitty"),
        )
      '';

      # Application plugin configuration
      extraConfigFiles."websearch.ron".text = ''
        Config(
          prefix: "?",
          
          engines: [
            Google, 
            Custom(
              name: "Nixos Unstable",
              url: "search.nixos.org/packages?query={}",
            ),
          ],
        )
      '';

      # Symbols plugin configuration
      extraConfigFiles."symbols.ron".text = ''
        Config(
          prefix: ":sb",
          symbols: {
            "shrug": "¯\\_(ツ)_/¯",
          },
           max_entries: 3,
        )
      '';

      # Translate plugin configuration
      # <prefix><target lang> <text to translate>
      # or
      # <prefix><src lang><language_delimiter><target lang> <text to translate>
      extraConfigFiles."translate.ron".text = ''
        Config(
          prefix: ":t",
          language_delimiter: ">",
           max_entries: 4,
        )
      '';

      # Shell plugin configuration
      extraConfigFiles."shell.ron".text = ''
        Config(
          prefix: ":sh",
          shell: Some("fish"),
        )
      '';

      # Dictionary plugin configuration
      extraConfigFiles."dictionary.ron".text = ''
        Config(
          prefix: ":def",
        )
      '';
    };
  };
}
