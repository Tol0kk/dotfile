{ inputs, ... }:
{
  flake.homeModules.sops =
    { config, ... }:
    {
      imports = [ inputs.sops-nix.homeModules.sops ];

      config = {
        sops.age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        sops.defaultSopsFormat = "yaml";
      };
    };

  flake.nixosModules.sops =
    {
      pkgs,
      lib,
      config,
      libCustom,
      ...
    }:
    with lib;
    with libCustom;
    {
      key = "nixosModules.sops";
      options.modules.system.sops = {
        keyFile = mkOpt types.str "" "Age Key file used to decrypt secrets";
        defaultSopsFile = mkOpt types.path null "Default Sops file to use.";
      };

      imports = [ inputs.sops-nix.nixosModules.sops ];
      config = {
        environment.systemPackages = with pkgs; [
          age
          sops
        ];

        sops.age.keyFile = config.modules.system.sops.keyFile;
        sops.defaultSopsFormat = "yaml";
        # sops.defaultSopsFile = cfg.defaultSopsFile;
        sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      };
    };
}
