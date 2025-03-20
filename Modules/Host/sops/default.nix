{
  pkgs,
  lib,
  config,
  inputs,
  self,
  mainUser,
  ...
}:
with lib; let
  cfg = config.modules.sops;
in {
  options.modules.sops = {
    enable = mkOption {
      description = "Enable Sops secrets management";
      type = types.bool;
      default = false;
    };
  };

  imports = [inputs.sops-nix.nixosModules.sops];
  config = mkIf cfg.enable {
    fileSystems."/home".neededForBoot = true;
    environment.systemPackages = with pkgs; [
      age
      sops
    ];

    sops.age.keyFile = "${config.users.users.${mainUser}.home}/.config/sops/age/keys.txt";
    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = "${self}/secrets/secrets.yaml";

    sops.secrets."${mainUser}/email" = {owner = mainUser;};
    sops.secrets."${mainUser}/firstname" = {owner = mainUser;};
    sops.secrets."${mainUser}/lastname" = {owner = mainUser;};
  };
}
