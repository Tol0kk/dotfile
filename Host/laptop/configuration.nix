{ pkgs
, config
, lib
, ...
}:

{
  modules = {
    bluetooth.enable = true;
    workstation = {
      enable = true;
      hypr.enable = true;
      gnome.enable = true;
    };
    syncthing.enable = true;
    fonts.enable = true;
    tools.security.enable = true;
    gaming.enable = true;
    nvidia = {
      enable = true;
      offload = {
        enable = false;
        intelBusId = "PCI:0:2:0";
        nvidiaBusId = "PCI:1:0:0";
      };
    };
    sops.enable = true;
    nixvim.enable = true;
    boot.grub.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.kvm.enable = true;
    # ttrss.enable = true;
    # virtualisation.virtualbox.enable = false;
    # virtualisation.waydroid.enable = false;
    # samba.enable = false;
    udev.enableExtraRules = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  # Prevent sshd to start automaticly on laptop. (make the system safer)
  systemd.services.sshd.wantedBy = lib.mkForce [ ];

  # services.fprintd = {
  # enable = true;
  # tod.enable = true;
  # tod.driver = pkgs.libfprint-2-tod1-goodix;
  # };
  # security.pam.services.${mainUser}.fprintAuth = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
