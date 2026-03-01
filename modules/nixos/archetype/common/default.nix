# Imported
{
  lib,
  pkgs,
  libCustom,
  config,
  assets,
  self,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.archetype.common;
in
{
  options.modules.archetype.common = {
    enable = mkEnableOpt "Enable Common archetype" // {
      default = true;
    };
  };

  options.dotfiles = lib.mkOption {
    type = lib.types.path;
    apply = toString;
    default = "${config.home.homeDirectory}/.config/nixos";
    example = "${config.home.homeDirectory}/.config/nixos";
    description = "Location of the dotfiles working copy";
  };

  # TODO assert that thereis at least one Normal user
  config = mkIf cfg.enable {
    # System generation label
    system.nixos.label =
      (builtins.concatStringsSep "-" (builtins.sort (x: y: x < y) config.system.nixos.tags))
      + config.system.nixos.version
      + (if (self ? rev) then "-SHA:${self.rev}" else "-impure");

    nix.optimise.automatic = true;
    nix.optimise.dates = [ "03:45" ];
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

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

    # Configure keymap
    services.xserver = {
      xkb.layout = "fr";
      xkb.variant = "";
    };
    console.useXkbConfig = true;

    # Deactivate channels, we use flake
    nix.channel.enable = false;
    nix.nixPath = [ "nixpkgs=flake:nixpkgs" ];

    networking.firewall.enable = true;
    networking.firewall.allowPing = false;
    networking.firewall.logReversePathDrops = true;

    # Make fish the default system wide
    users.defaultUserShell = pkgs.fish;
    programs.fish.enable = true;

    # Configure DNS server
    networking.nameservers = [
      "1.1.1.1"
      "0.0.0.0"
    ];

    # Setup neovim as default editor
    modules.apps.neovim = enabled;
    environment.variables.EDITOR = "nvim";

    environment.systemPackages = with pkgs; [
      # Basic apps
      wget
      git
      lsd
      ripgrep
      btop
      colmena
      tmux
      dig.dnsutils
      inetutils
      nmap
      jq
      tree
      rename
    ];

    environment.shellAliases = assets.shellAliases;
  };
}
