{
  pkgs,
  lib,
  config,
  inputs,
  libCustom,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.system.sops;
in {
  options.modules.system.sops = {
    enable = mkEnableOpt "Enable Sops secrets management";
    keyFile = mkOpt types.str null "Age Key file used to decrypt secrets";
  };

  imports = [inputs.sops-nix.nixosModules.sops];
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      age
      sops
    ];

    sops.age.keyFile = cfg.keyFile;
    sops.defaultSopsFormat = "yaml";
    fileSystems."/home".neededForBoot = strings.hasPrefix "/home" cfg.keyFile; # Make sure that /home is mounted for sops runtime a boot

    assertions = [
      {
          assertion = cfg.keyFile != null;
          message = ''
            You have to setup a keyFile to use Sops.
          '';
        }
    ];
  };
}
