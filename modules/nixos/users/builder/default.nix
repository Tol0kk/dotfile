{
  lib,
  libCustom,
  config,
  pkgs,
  ...
}:
with lib;
with libCustom;
let
  cfg = config.modules.users.builder;
in
{
  options.modules.users.builder = {
    enable = mkEnableOpt "Enable Builder user";
  };

  config = mkIf cfg.enable {
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
  };
}
