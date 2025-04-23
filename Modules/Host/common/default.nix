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
        "sniffnet"
      ];
      useDefaultShell = true;
      createHome = true;
    };

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
      tree
      rename
    ];

    users.groups.sniffnet = {};

    security.wrappers.sniffnet = {
      source = "${pkgs.sniffnet}/bin/sniffnet";
      capabilities = "cap_net_raw,cap_net_admin+eip";
      owner = "root";
      group = "sniffnet";
      permissions = "u+rx,g+x";
    };

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
        Host dekstop # Replace by IP address, or add a ProxyCommand, see man ssh_config for full docs.
          # Prevent using ssh-agent or another keyfile, useful for testing
          IdentitiesOnly yes
          IdentityFile /root/.ssh/nixremote
          # The weakly privileged user on the remote builder – if not set, 'root' is used – which will hopefully fail
          User builder
      '';
    };
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };

    nix.buildMachines = [
      {
        hostName = "desktop";
        systems = ["x86_64-linux" "aarch64-linux"];
        protocol = "ssh";
        sshUser = "builder";
        maxJobs = 1;
        speedFactor = 2;
        supportedFeatures = ["nixos-test" "benchmark" "big-parallel" "kvm"];
        mandatoryFeatures = [];
      }
    ];
    nix.distributedBuilds = true;
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
