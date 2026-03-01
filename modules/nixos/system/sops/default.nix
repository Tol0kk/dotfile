# Imported
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
with libCustom;
let
  cfg = config.modules.system.sops;
in
{
  options.modules.system.sops = {
    enable = mkEnableOpt "Enable Sops secrets management";
    keyFile = mkOpt types.str "" "Age Key file used to decrypt secrets";
    defaultSopsFile = mkOpt types.path null "Default Sops file to use.";
  };

  imports = [ inputs.sops-nix.nixosModules.sops ];
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      age
      sops
    ];

    sops.age.keyFile = cfg.keyFile;
    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = cfg.defaultSopsFile;
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # assertions = [
    #   {
    #     assertion = cfg.keyFile != null;
    #     message = ''
    #       You have to setup a keyFile to use Sops.
    #     '';
    #   }
    # ];
  };
}
