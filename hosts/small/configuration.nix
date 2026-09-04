{
  self,
  config,
  pkgs,
  lib,
  modulesPath,
  ...
}:
{
  # ── Topology / service catalogue ────────────────────────────────────────
  topology.self = {
    name = "Small VM";
    hardware.info = "VM";
  };

  nix. = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [ "https://cache.nixos.org" ];
  };

  environment.systemPackages = with pkgs; [
    git
    btrfs-progs
    gptfdisk
    parted
    util-linux
    cryptsetup
    nix-output-monitor
  ];

  # Not strictly needed, but handy if you want to scp things in or out.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
    settings.PermitEmptyPasswords = "yes";
  };
  security.pam.services.sshd.allowNullPassword = true;

  # ── Miscs ────────────────────────────────────────
  security.sudo.wheelNeedsPassword = false;

  networking.hostId = "54c7f0c1";
}
