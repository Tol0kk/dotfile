{ pkgs, mainUser, ... }:

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
    console.keyMap = "fr";

    # Configure keymap in X11
    services.xserver = {
      xkb.layout = "fr";
      xkb.variant = "";
    };

    # nix.channel.enable = false;
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

    users.users.${mainUser} = {
      isNormalUser = true;
      extraGroups = [
        "scanner"
        "lp"
        "mpd"
        "storage"
        "networkmanager"
        "wheel"
        "wireshark"
        "docker"
        "libvirtd"
        "input"
      ];
      useDefaultShell = true;
      createHome = true;
    };
    users.defaultUserShell = pkgs.fish;

    # Configure console keymap
    programs.fish.enable = true;

    environment.systemPackages = with pkgs; [
      wget
      neovim
      git
      zoxide
      lsd
      ntfs3g
      ripgrep
      btop
      colmena
    ];
    environment.variables.EDITOR = "nvim";

    boot.supportedFilesystems = [ "ntfs" ];

    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
      settings.KbdInteractiveAuthentication = false;
      knownHosts.titouan.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKzcm3GzMAzxobh8g3xGwI4RbgKLUc9k4mm+bT4MXtH titouan.le.dilavrec@gmail.com";
      knownHosts.root.publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKzcm3GzMAzxobh8g3xGwI4RbgKLUc9k4mm+bT4MXtH titouan.le.dilavrec@gmail.com";
    };
  };
}
