{
  pkgs,
  mainUser,
  pkgs-unstable,
  ...
}: {
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

    nix.channel.enable = false;
    nix.nixPath = ["nixpkgs=flake:nixpkgs"];

    networking.firewall.enable = true;
    networking.firewall.allowPing = false;
    networking.firewall.logReversePathDrops = true;

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
        "adbusers"
      ];
      useDefaultShell = true;
      createHome = true;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuwJLenPhKU+HBxEF1X/pgfU21b5Mr03gRxVrGb5ds+ titouan.le.dilavrec@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEKzcm3GzMAzxobh8g3xGwI4RbgKLUc9k4mm+bT4MXtH titouan.le.dilavrec@gmail.com"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      ];
    };

    zramSwap.enable = true;
    users.defaultUserShell = pkgs.fish;

    # Configure console keymap
    programs.fish.enable = true;

    networking.nameservers = [
      "1.1.1.1"
      "0.0.0.0"
    ];

    environment.systemPackages = with pkgs; [
      wget
      git
      zoxide
      lsd
      ntfs3g
      ripgrep
      btop
      colmena
      tmux
      jq
      bedtools
    ];
    environment.variables.EDITOR = "nvim";
    boot.supportedFilesystems = ["ntfs"];

    # SSH

    environment.shellAliases = import ./aliases.nix;

    programs.ssh = {
      extraConfig = ''
        Host servrock.tolok.org
          ProxyCommand ${pkgs-unstable.cloudflared}/bin/cloudflared access ssh --hostname %h
        Host desktop.tolok.org
          ProxyCommand ${pkgs-unstable.cloudflared}/bin/cloudflared access ssh --hostname %h
        Host laptop.tolok.org
          ProxyCommand ${pkgs-unstable.cloudflared}/bin/cloudflared access ssh --hostname %h
      '';
    };
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
