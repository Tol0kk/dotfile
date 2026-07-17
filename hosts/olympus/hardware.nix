{
  lib,
  modulesPath,
  ...
}:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/99e912d9-e206-4eec-9e23-c4e98000200a";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/486d-5457";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/47f86222-aef8-4c87-9d2d-20c6255b542a"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
