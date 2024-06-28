{ pkgs, lib, config, inputs, self, ... }:

with lib;
let
  cfg = config.modules.sops;
in
{
  options.modules.sops = {
    enable = mkOption {
      description = "Enable Sops secrets management";
      type = types.bool;
      default = false;
    };
  };

  imports = [ inputs.sops-nix.nixosModules.sops ];
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      age
      sops
    ];

    sops.age.keyFile = "/home/titouan/.config/sops/age/personal_key.txt"; 
    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

    sops.secrets."personal/email" = { owner = "titouan"; };
    sops.secrets."personal/firstname" = { };
    sops.secrets."personal/lastname" = { };
    sops.secrets."services/vaultwarden" = { };
    sops.secrets."services/vpn" = { };
  };
}
