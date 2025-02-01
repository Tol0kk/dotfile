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
    boot.grub.enable = true;
    # virtualisation.docker.enable = true;
    virtualisation.kvm.enable = true;
    neovim.custom.minimal = false;
  };

  powerManagement.cpuFreqGovernor = "performance";
  powerManagement.enable = true;

  boot.binfmt.emulatedSystems = [ "i686-linux" "aarch64-linux" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
