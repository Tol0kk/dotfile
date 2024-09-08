{ pkgs
, self
, inputs
, mainUser
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
    virtualisation.kvm.enable = false;
    # virtualisation.virtualbox.enable = false;
    # virtualisation.waydroid.enable = false;
    # samba.enable = false;
    # udev.enableSExtraRules = true;
  };
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };


  # services.fprintd = {
  # enable = true;
  # tod.enable = true;
  # tod.driver = pkgs.libfprint-2-tod1-goodix;
  # };
  # security.pam.services.${mainUser}.fprintAuth = true;

  system.stateVersion = "24.05"; # Did you read the comment?
}
