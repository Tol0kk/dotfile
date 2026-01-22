{
  pkgs,
  config,
  inputs,
  libCustom,
  self,
  lib,
  ...
}: let
  kernelConfig = with lib.kernel; {
    # arch/arm64/Kconfig.platforms
    ARCH_ROCKCHIP = yes;

    # drivers/clocksource/Kconfig
    ROCKCHIP_TIMER = yes;

    # drivers/clk/rockchip/Kconfig
    CLK_RK3588 = yes;

    # drivers/clk/rockchip/Kconfig
    COMMON_CLK_ROCKCHIP = yes;

    # drivers/net/phy/Kconfig
    ROCKCHIP_PHY = yes; # Currently supports the integrated Ethernet PHY.

    # drivers/phy/rockchip/Kconfig
    PHY_ROCKCHIP_EMMC = yes; # Enable this to support the Rockchip EMMC PHY.
    # PHY_ROCKCHIP_INNO_HDMI = yes; # Enable this to support the Rockchip Innosilicon HDMI PHY.
    PHY_ROCKCHIP_INNO_USB2 = yes; # Support for Rockchip USB2.0 PHY with Innosilicon IP block.
    PHY_ROCKCHIP_PCIE = yes; # Enable this to support the Rockchip PCIe PHY.
    PHY_ROCKCHIP_SNPS_PCIE3 = yes; # Enable this to support the Rockchip snps PCIe3 PHY.
    PHY_ROCKCHIP_TYPEC = yes; # Enable this to support the Rockchip USB TYPEC PHY.
    PHY_ROCKCHIP_USB = yes; # Enable this to support the Rockchip USB 2.0 PHY.

    # drivers/gpu/drm/rockchip/Kconfig
    # DRM_ROCKCHIP = yes;
    # ROCKCHIP_VOP2 = yes;

    # drivers/media/platform/rockchip/rga/Kconfig
    VIDEO_ROCKCHIP_RGA = module; # This is a v4l2 driver for Rockchip SOC RGA 2d graphics accelerator.
    # Rockchip RGA is a separate 2D raster graphic acceleration unit.
    # It accelerates 2D graphics operations, such as point/line drawing,
    # image scaling, rotation, BitBLT, alpha blending and image blur/sharpness.

    # drivers/media/platform/verisilicon/Kconfig
    VIDEO_HANTRO = module; # Enable Hantro VPU driver - hardware video encoding/decoding acceleration for H.264, HEVC, VP8, VP9, JPEG
    VIDEO_HANTRO_HEVC_RFC = yes; # Enable HEVC reference frame compression - saves memory bandwidth but uses more RAM for HEVC codec
    VIDEO_HANTRO_ROCKCHIP = yes;

    # # drivers/soc/rockchip/Kconfig
    # ROCKCHIP_IODOMAIN = yes; # Enable support io domains on Rockchip SoCs.
    # ROCKCHIP_DTPM = yes; # Describe the hierarchy for the Dynamic Thermal Power Management tree
    # # on this platform. That will create all the power capping capable devices.

    # # drivers/gpio/Kconfig
    # GPIO_ROCKCHIP = yes;

    # SND_SOC_ROCKCHIP = yes;            # Enable Rockchip SoC audio framework - core audio support for Rockchip chips
    # SND_SOC_ROCKCHIP_I2S = yes;        # Enable I2S audio driver - digital audio interface for codecs and audio devices
    # SND_SOC_ROCKCHIP_I2S_TDM = yes;    # Enable I2S/TDM driver - multi-channel audio and time division multiplexing support
    # SND_SOC_ROCKCHIP_PDM = yes;        # Enable PDM driver - pulse density modulation for digital MEMS microphones
    # SND_SOC_ROCKCHIP_SPDIF = yes;      # Enable SPDIF driver - Sony/Philips digital audio output for home theater systems

    # # drivers/spi/Kconfig
    # SPI_ROCKCHIP = yes;
    # SPI_ROCKCHIP_SFC = yes;

    # # drivers/pmdomain/rockchip/Kconfig
    # ROCKCHIP_PM_DOMAINS = yes;
  };
in
  with libCustom; {
    boot.kernelModules = [
      "rockchip_vdec"
      "rockchipdrm"
      "hantro_vpu"
    ];

    boot.initrd.kernelModules = [
      "rockchipdrm"
    ];

    # boot.kernelPatches = [
    #   {
    #     name = "rockchip-video-accel";
    #     patch = null;
    #     extraStructuredConfig = with lib.kernel; {
    #       ARCH_ROCKCHIP = yes;
    #       # VIDEO_ROCKCHIP_RGA = module; # This is a v4l2 driver for Rockchip SOC RGA 2d graphics accelerator.
    #       # DRM_ROCKCHIP = yes;
    #     };
    #   }
    # ];

    # services.udev.extraRules = ''
    #   KERNEL=="mpp_service", MODE="0660", GROUP="video"
    #   KERNEL=="rkvdec", MODE="0660", GROUP="video"
    #   KERNEL=="rkvenc", MODE="0660", GROUP="video"
    #   KERNEL=="vepu", MODE="0660", GROUP="video"
    #   KERNEL=="vpu_service", MODE="0660", GROUP="video"
    # '';
    #
    hardware.deviceTree.enable = true;

    # boot.kernelPackages = pkgs.linuxKernel.packagesFor (
    #   pkgs.linuxKernel.manualConfig rec {
    #     version = "6.1.115";
    #     modDirVersion = version;

    #     src = pkgs.fetchFromGitHub {
    #       owner = "armbian";
    #       repo = "linux-rockchip";
    #       rev = "rk-6.1-rkr5.1"; # Check for latest branch
    #       sha256 = "sha256-6ii2iFm7wcMhUOA5D9psB0Aqs8k/bimX9E0zuikmKPg="; # You'll need to fill this
    #     };

    #     configfile = ./rockchip-rk3588.config; # Extract from Armbian

    #     kernelPatches = [ ];
    #     allowImportFromDerivation = true;
    #   }
    # );

    # Work bu no data tree
    # boot.kernelPackages = pkgs.linuxKernel.packagesFor (
    #   pkgs.linuxKernel.kernels.linux_6_12.override {
    #     extraStructuredConfig = with lib.kernel; {
    #       ARCH_ROCKCHIP = yes;
    #       VIDEO_ROCKCHIP_RGA = module; # This is a v4l2 driver for Rockchip SOC RGA 2d graphics accelerator.
    #       DRM_ROCKCHIP = yes;

    #       VIDEO_HANTRO = module; # Enable Hantro VPU driver - hardware video encoding/decoding acceleration for H.264, HEVC, VP8, VP9, JPEG
    #       VIDEO_HANTRO_HEVC_RFC = yes; # Enable HEVC reference frame compression - saves memory bandwidth but uses more RAM for HEVC codec
    #       VIDEO_HANTRO_ROCKCHIP = yes;
    #     };
    #   }
    # );
    # boot.kernelPackages = pkgs.linuxPackages_6_1;

    modules = {
      users = {
        odin = enabled;
      };
      system = {
        boot.systemd = enabled;
        sops.enable = true;
        sops.keyFile = "${config.users.users.odin.home}/.config/sops/age/keys.txt";
        ssh.enable = true;
        ssh.auto-start-sshd = true;
      };
      archetype.server = enabled;

      services = {
        prometheus-node-exporter = enabled;
        home-assistant.enable = true;
      };

      server = {
        cloudflared = {
          enable = true;
          domain = "tolok.org";
          tunnelId = "ab1ecc34-4d1c-4356-88e7-ba7889c654ad";
        };
        media-center = {
          deluge.enable = true;
          jellyfin.enable = true;
        };
        matrix-conduit.enable = true;
        forgejo.enable = true;
        grafana.enable = true;
        kanidm.enable = true;
        wireguard.enable = true;
        glance.enable = true;
        prometheus.enable = true;
        loki.enable = true;
        promtail.enable = true;
        # prometheus-node-exporter.enable = true;
        own-cloud.enable = true;
        # esp-home.enable = true;
        uptime-kuma.enable = true;
        # home-assistant.enable = true;
        vaultwarden.enable = true;
        fail2ban.enable = true;
      };
    };

    # Optional: Information Given for generating systems topology
    topology.self = {
      name = "Olympus";
      hardware.info = "Radxa 5B | 16GB";
    };

    systemd.network.enable = true;
    systemd.network.networks.enP4p1s0 = {
      matchConfig.Name = "enP4p1s0";
      address = ["192.168.1.48/24"];
    };

    # Cross Compile
    # nixpkgs.config.allowUnsupportedSystem = true;

    # Boot
    boot.loader.systemd-boot.enable = true;
    # Limit the number of configuration, Useful to prevent boot partition running out of disk space.
    boot.loader.systemd-boot.configurationLimit = 10;
    boot.loader.efi.efiSysMountPoint = "/boot";
    boot.loader.efi.canTouchEfiVariables = true;
    boot.loader.grub.enable = false;
    networking.networkmanager.enable = true;

    programs.command-not-found.enable = false;
    services.resolved.enable = false;
    # networking.dhcpcd.persistent = true;

    # networking.enableIPv6 = true;
    # networking.useDHCP = true;

    # system.stateVersion = "24.05"; # Did you read the comment?

    # networking.defaultGateway = {
    #   address = "192.168.1.1";
    #   interface = "ens3";
    # };
    # networking.defaultGateway6 = {
    #   address = "2a02:842a:3ba7:a201::1";
    #   interface = "ens3";
    # };
    networking.interfaces.enP4p1s0.ipv6.addresses = [
      {
        address = "2a02:842a:3ba7:a201:b188:2909:4e2a:7f50";
        prefixLength = 64;
      }
    ];

    # Server Service #
    # CloudFlare Tunnels
    sops.secrets."services/cloudflared_HOME_TOKEN" = {};
    services.cloudflared = {
      tunnels = {
        "${config.modules.server.cloudflared.tunnelId}" = {
          credentialsFile = "${config.sops.secrets."services/cloudflared_HOME_TOKEN".path}";
          ingress = {
            "www.tolok.org" = {
              service = "http://localhost:8000";
              path = "/index.html";
            };
            "servrock.tolok.org" = {
              service = "ssh://servrock:22";
            };
            "desktop.tolok.org" = {
              service = "ssh://desktop:22";
            };
            "laptop.tolok.org" = {
              service = "ssh://laptop:22";
            };
          };
          default = "http_status:404";
        };
      };
    };

    services.dbus.implementation = "broker";

    # Fix shell
    environment.shellInit = ''
      export TERM=xterm
    '';

    users.users.odin = {
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID0FfndDkmaTNmM4XRWe5Qi1avRbhmNEGAjvJWr4GR9t titouan@laptop"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK7QCPO6Pc8Ir/lNbKK5YS0OwyLKtGFweL9K+Gd7MvFv personal@tolok.org"
      ];
    };

    # Important: for deploying without since we can't enter pasword with colmena
    security.sudo.extraRules = [
      {
        users = ["odin"];
        commands = [
          {
            command = "ALL";
            options = ["NOPASSWD"];
          }
        ];
      }
    ];
    nix.settings.trusted-users = ["odin"];

    environment.systemPackages = with pkgs; [
      pkgs.jellyfin
      pkgs.jellyfin-web
      (pkgs.jellyfin-ffmpeg.override {
        # Exact version of ffmpeg_* depends on what jellyfin-ffmpeg package is using.
        # In 24.11 it's ffmpeg_7-full.
        # See jellyfin-ffmpeg package source for details
        # ffmpeg_7-full = pkgs.rkffmpeg;
      })
      # pkgs.rkmpp

      ani-cli
      (pkgs.writeShellScriptBin "mount_zfs_pool" ''
        # Ask for the passphrase to unlock the LUKS-encrypted device
        echo -n "Enter the passphrase for /dev/sdb1: "
        read -s PASS

        echo "Decrypting..."

        # Open the LUKS volume
        echo "$PASS" | sudo ${pkgs.cryptsetup}/bin/cryptsetup open /dev/sdb1 zfs_crypt

        # Check if cryptsetup was successful
        if [ $? -ne 0 ]; then
        	echo "Failed to open LUKS device"
        	exit 1
        fi

        # Import the ZFS pool
        echo "Importing the ZFS pool 'datapool'..."
        sudo ${pkgs.zfs}/bin/zpool import datapool

        # Check if zpool import was successful
        if [ $? -ne 0 ]; then
        	echo "Failed to import ZFS pool"
        	exit 1
        fi

        echo "LUKS device unlocked and ZFS pool imported successfully."

      '')
    ];

    system.stateVersion = "24.11";

    # ZFS
    boot.supportedFilesystems = ["zfs"];
    boot.zfs.forceImportRoot = false;
    networking.hostId = "54c7f0c1";

    # Minecraft

    topology.self.services = {
      nix-minecraft = {
        name = "Minecraft";
        icon = "services.minecraft"; # TODO create service extractor
        info = "Minecraft Server 1.21.1";
        details.listen.text = "mc.tolok.org";
      };
    };

    imports = [inputs.nix-minecraft.nixosModules.minecraft-servers];
    nixpkgs.overlays = [inputs.nix-minecraft.overlay];

    services.minecraft-servers = {
      enable = true;
      eula = true;
      openFirewall = true;
      servers.vanilla = {
        enable = true;
        jvmOpts = "-Xmx4G -Xms2G";
        serverProperties = {
          server-port = 25565;
          difficulty = 3;
          motd = "NixOS Minecraft server!";
        };

        # Specify the custom minecraft server package
        package = pkgs.minecraftServers.vanilla-1_21_1;
      };
    };
  }
