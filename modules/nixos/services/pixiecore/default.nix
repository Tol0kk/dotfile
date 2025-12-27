{
  lib,
  config,
  libCustom,
  self,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.services.pixiecore;
  build = self.nixosConfigurations.netboot.config.system.build;
in
{
  options.modules.services.pixiecore = {
    enable = mkEnableOpt "Enable pixiecore, a iPXE server, allowing to netboot on this system";
  };

  config = mkIf cfg.enable {
    topology.self.services = {
      pixiecore = {
        name = "Pixiecore";
        icon = "services.adguardhome"; # TODO create service extractor
        info = lib.mkForce "iPXE netboot server";
      };
    };

    services.pixiecore = {
      enable = cfg.enable;
      openFirewall = true;
      dhcpNoBind = true;
      # Boot on external iso
      # kernel = "https://boot.netboot.xyz";
      # OR
      # Boot on iso config
      mode = "boot";
      kernel = "${build.kernel}/bzImage";
      initrd = "${build.netbootRamdisk}/initrd";
      cmdLine = "init=${build.toplevel}/init loglevel=4";
      debug = true;

    };
  };
}
