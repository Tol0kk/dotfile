{
  lib,
  config,
  libCustom,
  self,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.services.pixiecore;
  build = self.nixosConfigurations.netboot.config.system.build;
in {
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

    assertions = [
      {
        assertion = !(cfg.pixiecore.enable && cfg.traefik.enable);
        message = ''
          Pixiecore and Traefik are mutually exclusive and cannot both be enabled. Pixiecore need port port 80.

          Current state:
          - modules.services.pixiecore.enable = ${lib.boolToString cfg.pixiecore.enable}
          - modules.services.traefik.enable = ${lib.boolToString cfg.traefik.enable}

          Please set one of them to false.
        '';
      }
    ];

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
