{
  self,
  config,
  ...
}:
{
  # ── Topology / service catalogue ────────────────────────────────────────
  topology.self = {
    name = "Olympus";
    hardware.info = "Radxa 5B | 16GB | 2TB";
  };

  # ── Modules Imports ────────────────────────────────────────
  imports = [
    # Archetype
    self.nixosModules.server # This import traefik modules
    self.nixosModules.odin

    self.nixosModules.limine

    # Services
    self.nixosModules.prometheus-node-exporter
    self.nixosModules.glance
    self.nixosModules.dyndns

    self.nixosModules.vaultwarden
  ];

  # ── Globals Preferences ────────────────────────────────────────
  preferences = {
    topDomain = "home.tolok.org";
    openFirewall = true;
    public = true;
    sso = "auth.othrys.tolok.org";
  };

  # ── Secrets Declaration ────────────────────────────────────────
  sops.secrets."cloudflare/api_env" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."cloudflare/dyndns" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."cloudflare/cloudflared" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."oauth2_proxy/clientSecret" = {
    sopsFile = ./secrets.yaml;
  };
  sops.secrets."oauth2_proxy/secretSeed" = {
    sopsFile = ./secrets.yaml;
  };

  # ── Modules Settings ────────────────────────────────────────
  modules.services = {
    prometheus-node-exporter.public = false;
  };

  # ── Cloudflared Tunels ────────────────────────────────────────
  services.cloudflared = {
    tunnels = {
      "ab1ecc34-4d1c-4356-88e7-ba7889c654ad" = {
        credentialsFile = "${config.sops.secrets."cloudflare/cloudflared".path}";
        ingress = {
          "desktio.hosts.tolok.org" = {
            service = "ssh://desktop:22";
          };
          "laptop.hosts.tolok.org" = {
            service = "ssh://laptop:22";
          };
        };
        default = "http_status:404";
      };
    };
  };

  # ── Miscs ────────────────────────────────────────
  security.sudo.wheelNeedsPassword = false;

  # ZFS
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "54c7f0c1";
}
