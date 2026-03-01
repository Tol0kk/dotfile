# Imported
{
  lib,
  libCustom,
  config,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.system.remote-builder;
in
{
  options.modules.system.remote-builder = {
    enable = mkEnableOpt "Enable remote builder";
  };

  config = mkIf cfg.enable {
    modules.system.ssh = enabled;
    programs.ssh = {
      extraConfig = ''
        Host builder # Replace by IP address, or add a ProxyCommand, see man ssh_config for full docs.
          # Prevent using ssh-agent or another keyfile, useful for testing
          IdentitiesOnly yes
          IdentityFile /root/.ssh/builder@desktop
          # The weakly privileged user on the remote builder – if not set, 'root' is used – which will hopefully fail
          User builder
          HostName desktop
      '';
    };
    nix.buildMachines = [
      {
        # Add desktop remote builder
        hostName = "builder";
        systems = [
          "x86_64-linux"
          "aarch64-linux"
        ];
        protocol = "ssh-ng";
        sshUser = "builder";
        maxJobs = 16;
        speedFactor = 30;
        supportedFeatures = [
          "nixos-test"
          "benchmark"
          "big-parallel"
          "kvm"
        ];
        mandatoryFeatures = [ ];
      }
    ];
    nix.distributedBuilds = true;
    nix.extraOptions = ''
      builders-use-substitutes = true
    '';
  };
}
