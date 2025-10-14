{
  pkgs,
  lib,
  config,
  inputs,
  libCustom,
  self,
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
    sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

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
