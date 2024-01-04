{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.common;
in
{
  options.modules.common = {
    enable = mkOption {
      description = "Enable common modules";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Set your time zone.
    time.timeZone = "Europe/Paris";

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };

    # Configure keymap in X11
    services.xserver = {
      layout = "fr";
      xkbVariant = "";
    };

    # Configure console keymap
    console.keyMap = "fr";

    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.titouan = {
      isNormalUser = true;
      description = "titouan";
      extraGroups = [ "networkmanager" "wheel" ];
      packages = with pkgs; [ ];
    };
    users.defaultUserShell = pkgs.fish;

    # Allow unfree packages
    security.sudo.wheelNeedsPassword = false;
    security.polkit.enable = true;
    systemd = {
      user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
          RestartSec = 1;
          TimeoutStopSec = 10;
        };
      };
    };

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    services.openssh.enable = true;

    programs.nix-index.enable = true;
    programs.nix-index.enableZshIntegration = true;
    programs.nix-index.enableFishIntegration = true;
    programs.nix-index.enableBashIntegration = true;
    programs.command-not-found.enable = false;

    xdg.mime.defaultApplications = {
      "application/pdf" = [
        "zathura.desktop"
        "brave-browser.desktop"
      ];
      "image/png" = [
        "sxiv.desktop"
        "gimp.desktop"
      ];
    };

  };
}
