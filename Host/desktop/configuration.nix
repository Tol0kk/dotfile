{
  mainUser,
  pkgs,
  ...
}: {
  modules = {
    bluetooth.enable = true;
    workstation = {
      enable = true;
      hypr.enable = true;
      gnome.enable = true;
    };
    fonts.enable = true;
    sops.enable = true;
    tools.security.enable = true;
    gaming.enable = true;
    nvidia.enable = true;
    boot.grub.enable = true;
    virtualisation.kvm.enable = true;
    neovim.custom.minimal = false;
  };

  users.users.${mainUser} = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
    ];
  };

  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.luks.devices."luks-c19801cf-8ba0-488b-97d1-959651c21ab9".device = "/dev/disk/by-uuid/c19801cf-8ba0-488b-97d1-959651c21ab9";

  boot.initrd.systemd.enable = true;

  boot = {
    plymouth = {
      enable = true;
      theme = "cubes";
      themePackages = with pkgs; [
        # By default we would install all themes
        (adi1090x-plymouth-themes.override {
          selected_themes = ["cubes"];
        })
      ];
    };

    # Enable "Silent Boot"
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };

  services.xserver.displayManager.autoLogin.enable = true;
  services.xserver.displayManager.autoLogin.user = "titouan";

  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.enable = true;

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  system.stateVersion = "24.11"; # Did you read the comment?

  # Builder User
  users.users.builder = {
    createHome = false;
    isNormalUser = true;
    homeMode = "500";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIX59IeMArYX5K3SQDzWQj6qqy2D2IGyanwQAjDrbJzz builder@desktop"
    ];
    useDefaultShell = false;
    shell = pkgs.bashInteractive;
    group = "builders";
  };
  nix.settings.trusted-users = ["builder"];
}
