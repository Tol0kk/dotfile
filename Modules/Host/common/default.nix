{ pkgs, ... }:

{
  config = {
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
      xkb.layout = "fr";
      xkb.variant = "";
    };

      programs.ssh.startAgent = true;

    # Configure console keymap
    console.keyMap = "fr";
    programs.fish.enable = true;

    environment.systemPackages = with pkgs; [
      wget
      neovim
      git
      zoxide
      lsd
      ntfs3g
      ripgrep
    ];
    environment.variables.EDITOR = "nvim";
    boot.supportedFilesystems = [ "ntfs" ];
    programs.nix-index.enable = true;
    programs.nix-index.enableZshIntegration = true;
    programs.nix-index.enableFishIntegration = true;
    programs.nix-index.enableBashIntegration = true;
    programs.command-not-found.enable = false;
    programs.direnv.enable = true;
    programs.direnv.silent = true;
    programs.direnv.nix-direnv.enable = true;

    services.openssh.enable = true;

    # Allow unfree packages
    # security.polkit.enable = true;
    # systemd = {
    #   user.services.polkit-gnome-authentication-agent-1 = {
    #     description = "polkit-gnome-authentication-agent-1";
    #     wantedBy = [ "graphical-session.target" ];
    #     wants = [ "graphical-session.target" ];
    #     after = [ "graphical-session.target" ];
    #     serviceConfig = {
    #       Type = "simple";
    #       ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
    #       Restart = "on-failure";
    #       RestartSec = 1;
    #       TimeoutStopSec = 10;
    #     };
    #   };
    # };

    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    # };
    # services.openssh.enable = true;



    # xdg.mime.defaultApplications = {
    #   "application/pdf" = [
    #     "zathura.desktop"
    #     "firefox.desktop"
    #   ];
    #   "image/png" = [
    #     "sxiv.desktop"
    #     "gimp.desktop"
    #   ];
    # };

  };
}
