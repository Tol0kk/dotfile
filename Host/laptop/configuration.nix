{ pkgs
, self
, inputs
, mainUser
, ...
}:

{
  modules = {
    # bluetooth.enable = true;
    workstation = {
      enable = true;
      hypr.enable = true;
      gnome.enable = true;
    };
    fonts.enable = true;
    tools.security.enable = true;
    gaming.enable = true;
    nvidia = {
      enable = false;
      offload = {
        enable = true;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    # nixvim.enable = true;
    boot.grub.enable = true;
    # virtualisation.docker.enable = true;
    virtualisation.kvm.enable = true;
    # virtualisation.virtualbox.enable = false;
    # virtualisation.waydroid.enable = false;
    # samba.enable = false;
    # udev.enableSExtraRules = true;
  };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${mainUser} = {
      description = "Main user of the laptop.";
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


  services.fprintd = {
	enable = true;
	tod.enable = true;
	tod.driver = pkgs.libfprint-2-tod1-goodix;
  };
  security.pam.services.${mainUser}.fprintAuth = true;

 

  system.stateVersion = "24.05"; # Did you read the comment?
}
