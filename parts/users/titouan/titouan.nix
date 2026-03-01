{ self, inputs, ... }:
{
  flake.homeModules.titouan =
    {
      lib,
      libCustom,
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        # Apps
        self.homeModules.vscode
        self.homeModules.zed
        self.homeModules.alacritty
        self.homeModules.git
        self.homeModules.kitty
        self.homeModules.mpv
        self.homeModules.zathura

        # Shells
        self.homeModules.fish
        self.homeModules.bash

        # Desktop Env
        self.homeModules.niri

        # Services
        self.homeModules.elements
        self.homeModules.signal

        # System
        self.homeModules.sops
      ];
    };

  flake.homeModules."titouan@laptop" = {
    imports = [
      self.homeModules.titouan
    ];
    # Extra set for syncthings
  };

  flake.homeModules."titouan@desktop" = {
    imports = [
      self.homeModules.titouan
    ];
    # Extra set for syncthings
  };

  flake.nixosModules.titouan = {
    nix.settings.trusted-users = [ "titouan" ];
    users.users.titouan = {
      isNormalUser = true;
      extraGroups = [
        "scanner"
        "lp"
        "mpd"
        "storage"
        "networkmanager"
        "wireshark"
        "docker"
        "libvirtd"
        "input"
        "adbusers"
        "gamemode"
        "dialout" # Acess to /dev/ttyUSBX
        "wheel"
      ];
      useDefaultShell = true;
      createHome = true;
      initialPassword = "nixos";
    };

    users.users.titouan = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
      ];
    };
  };

  flake.nixosModules.titouan-home =
    {
      config,
      pkgs,
      nixpkgs,
      pkgs-unstable,
      nixpkgsconfig,
      ...
    }:
    {
      imports = [
        self.nixosModules.homemanager
      ];
      home-manager.users.titouan = {
        imports = [
          self.homeModules.titouan
          self.homeModules.homemanager
        ];
        nixpkgs = {
          inherit (nixpkgsconfig) config overlays;
        };
      };
    };
  flake.nixosModules.titouan-autologin =
    { pkgs, ... }:
    {
      services.greetd.enable = true;
      services.greetd.settings.initial_session.user = "titouan";
    };
}
