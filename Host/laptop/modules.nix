{ self, lib, config, pkgs, inputs, ... } @ inputss:
{
  config.modules = {
    fonts.enable = true;
    nvidia.enable = true;
    virtualisation.enable = true;
    virtualisation.virtualbox.enable = true;
    virtualisation.docker.enable = true;
    virtualisation.waydroid.enable = true;
  };
}
