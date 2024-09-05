{ pkgs
, self
, inputs
, mainUser
, config
, pkgs-unstable
, ...
}:

{
  modules = {
    bluetooth.enable = true;
    workstation = {
      enable = true;
      hypr.enable = true;
      gnome.enable = true;
    };
    fonts.enable = true;
    # gitea.enable = true;
    sops.enable = true;
    tools.security.enable = true;
    gaming.enable = true;
    nvidia.enable = true;
    # nixvim.enable = true;
    boot.grub.enable = true;
    # virtualisation.docker.enable = true;
    virtualisation.kvm.enable = true;
    # virtualisation.virtualbox.enable = false;
    # virtualisation.waydroid.enable = false;
    # samba.enable = false;
    # udev.enableSExtraRules = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${mainUser} = {
    isNormalUser = true;
    extraGroups = [
      "scanner"
      "lp"
      "mpd"
      "storage"
      "networkmanager"
      "wheel"
      "wireshark"
      "docker"
      "libvirtd"
      "input"
    ];
  };
  users.defaultUserShell = pkgs.fish;
    hardware.graphics.enable = true;
  

  sops.secrets."services/cloudflared_HOME_TOKEN" = { owner = config.services.cloudflared.user; };
  # sops.secrets."services/cloudflared_HOME_TOKEN" = { owner = "titouan"; };
  services.cloudflared = {
    package = pkgs-unstable.cloudflared;
    enable = true;
    tunnels = {
      "ab1ecc34-4d1c-4356-88e7-ba7889c654ad" = {
        credentialsFile = "${config.sops.secrets."services/cloudflared_HOME_TOKEN".path}";
        ingress = {
           "python.home.toloklab.com" = {
            service = "http://localhost:8000";
            path = "/index.html";
          };
          "ssh.toloklab.com" = {
            path = "/desktop";
            service = "ssh://localhost:22";
          };
        };
        default = "http_status:404";
      };
    };
  };
  boot.kernel.sysctl."net.core.rmem_max" = 7500000;
  boot.kernel.sysctl."net.core.wmem_max" = 7500000;

  environment.systemPackages = with pkgs; [
    colmena
  ];

  boot.binfmt.emulatedSystems = [ "i686-linux" "aarch64-linux" ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
