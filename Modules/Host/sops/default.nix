{ pkgs, lib, config, inputs, self, mainUser, ... }:

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

    sops.age.keyFile = "${config.users.users.${mainUser}.home}/.config/sops/age/keys.txt"; 
    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

    sops.secrets."${mainUser}/email" = { owner = "titouan"; };
    sops.secrets."${mainUser}/firstname" = { };
    sops.secrets."${mainUser}/lastname" = { };
    sops.secrets."services/vaultwarden" = { };
    sops.secrets."services/vpn" = {  };
  };
}
