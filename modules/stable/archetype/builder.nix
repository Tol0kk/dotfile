# TODO check
{ self, ... }:
{
  flake.nixosModules.builder =
    {
      lib,
      pkgs,
      libCustom,
      config,
      ...
    }:
    {
      imports = [
        # Archetype
        self.nixosModules.server
      ];
      users.users.builder = {
        createHome = false;
        isNormalUser = true;
        homeMode = "500"; # Read only home directory
        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIX59IeMArYX5K3SQDzWQj6qqy2D2IGyanwQAjDrbJzz builder@desktop"
        ];
        useDefaultShell = false; # use bash only
        shell = pkgs.bashInteractive;
        group = "builders";
      };
      nix.settings.trusted-users = [ "builder" ];
      users.groups.builders = { };

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
