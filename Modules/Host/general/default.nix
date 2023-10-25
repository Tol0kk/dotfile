{ pkgs, lib, config, self, inputs, ... }:
with lib;
let cfg = config.modules.general;

in {
  options.modules.general = {
    systemPackages = mkOption {
      description = "Packages for home manager";
      type = types.listOf types.package;
      default = [ ];
    };
    sessionVariables = mkOption {
      description = "Packages for home manager";
      type = with types; attrsOf (oneOf [ (listOf str) str path ]);
      default = [ ];
    };
    sessionPath = mkOption {
      description = "Packages for home manager";
      type = with types; listOf str;
      default = [ ];
    };
  };

  config =
    (mkMerge [
      ({
        environment.systemPackages = [
          pkgs.eclipses.eclipse-java
        ];
        programs.java.enable = true;
        programs.java.package = pkgs.jdk17;
        documentation.dev.enable = true;


        ### Common Config Across Any Machine

        # Set Default User on the system. User should be suders
        users.users.titouan = {
          isNormalUser = true;
          description = "titouan";
          shell = pkgs.fish;
          extraGroups = [ "wireshark" "libvirtd" "seat" "networkmanager" "wheel" "audio" "video" "docker" "adbusers" "dialout" ];
          packages = with pkgs; [ ];
        };
        security.sudo.wheelNeedsPassword = false;
        programs.fish.enable = true;

        # Enable the OpenSSH daemon.
        services.openssh.enable = true;
        services.openssh.knownHosts."github.com".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
        security.pam.enableSSHAgentAuth = true;
        # security.pam.services.sudo.sshAgentAuth = true;
        services.openssh.settings.PasswordAuthentication = false;
        programs.ssh.startAgent = true;

        # NTFS Support
        boot.supportedFilesystems = [ "ntfs" ];

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;

        # Setup Nix Index insted of command-ot-found.
        programs.nix-index.enable = true;
        programs.nix-index.enableZshIntegration = true;
        programs.nix-index.enableFishIntegration = true;
        programs.nix-index.enableBashIntegration = true;
        programs.command-not-found.enable = false;

        # Add experimental features
        nix.settings.experimental-features = [ "nix-command" "flakes" ];

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


        environment.sessionVariables = {
          TEST_SOPS = config.sops.secrets.example_key.path;
        };

      })
      ({
        environment.systemPackages = cfg.systemPackages;
      })
      ({
        environment.sessionVariables = cfg.sessionVariables;
      })
    ]);
}
