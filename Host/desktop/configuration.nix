{ pkgs
, self
, inputs
, mainUser
, config
, pkgs-unstable
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
    # gitea.enable = true;
    sops.enable = true;
    tools.security.enable = true;
    gaming.enable = true;
    nvidia.enable = true;
    nixvim.enable = false;
    boot.grub.enable = true;
    # virtualisation.docker.enable = true;
    virtualisation.kvm.enable = true;
    # virtualisation.virtualbox.enable = false;
    # virtualisation.waydroid.enable = false;
    # samba.enable = false;
    # udev.enableSExtraRules = true;
  };

  boot.binfmt.emulatedSystems = [ "i686-linux" "aarch64-linux" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
