{
  flake.nixosModules.laptop =
    {
      lib,
      libCustom,
      config,
      ...
    }:
    {
      ## Upower
      services.upower = {
        enable = true;
        percentageLow = 25;
        percentageCritical = 10;
        percentageAction = 5;
        criticalPowerAction = "HybridSleep";
      };

      ## Laptop Lid
      services.logind.settings.Login.HandleLidSwitch = "hybrid-sleep";
      services.logind.settings.Login.HandleLidSwitchExternalPower = "lock";
      services.logind.settings.Login.HandlelidSwitchDocked = "ignore";

      # Laptop power
      powerManagement.enable = true;
      powerManagement.powertop.enable = true;
      services.thermald.enable = true;

      environment.systemPackages = [
        config.boot.kernelPackages.cpupower
      ];

      zramSwap = {
        enable = true;
        # algorithm = "lzo-rle";
        memoryPercent = 100;
      };

      boot.kernel.sysctl = {
        # Aggressively use zram
        # Higher values will make the kernel prefer swapping out idle processes over dropping caches
        "vm.swappiness" = 180;
        "vm.watermark_boost_factor" = 0;
        "vm.watermark_scale_factor" = 125;
        "vm.page-cluster" = 0;
      };
    };
}
