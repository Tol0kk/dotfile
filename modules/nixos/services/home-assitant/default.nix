{
  libCustom,
  lib,
  config,
  ...
}:
with lib;
with libCustom; let
  cfg = config.modules.services.home-assistant;

  # TODO: Remove
  serverDomain = config.modules.server.cloudflared.domain;
  domain = "ha.${serverDomain}";
in {
  options.modules.services.home-assistant = {
    enable = mkEnableOpt "Enable Home Assistant container";

    dataDir = mkOption {
      type = types.path;
      default = "/var/lib/homeassistant";
      description = "Directory for Home Assistant data";
    };

    port = mkOption {
      type = types.port;
      default = 8123;
      description = "Port for Home Assistant web interface";
    };

    timezone = mkOption {
      type = types.str;
      default = "Europe/Paris";
      description = "Timezone for Home Assistant";
    };

    usbDevices = mkOption {
      type = types.listOf types.str;
      default = [
        "/dev/ttyUSB0"
        "/dev/ttyACM0"
      ];
      description = "USB/TTY devices to pass through to container";
      example = [
        "/dev/ttyUSB0"
        "/dev/ttyUSB1"
      ];
    };

    extraDevices = mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Additional devices to pass through";
      example = ["/dev/serial/by-id/usb-..."];
    };

    matterServer = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Matter server container";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/matter-server";
        description = "Directory for Matter server data";
      };

      port = mkOption {
        type = types.port;
        default = 5580;
        description = "Matter server WebSocket port";
      };
    };

    mosquitto = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Mosquitto MQTT broker";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/mosquitto";
        description = "Directory for Mosquitto data";
      };

      port = mkOption {
        type = types.port;
        default = 1883;
        description = "MQTT broker port";
      };

      websocketPort = mkOption {
        type = types.port;
        default = 9001;
        description = "MQTT WebSocket port";
      };
    };

    zigbee2mqtt = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Zigbee2MQTT";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/zigbee2mqtt";
        description = "Directory for Zigbee2MQTT data";
      };

      device = mkOption {
        type = types.str;
        default = "/dev/ttyUSB0";
        description = "Zigbee adapter device";
        example = "/dev/serial/by-id/usb-ITead_Sonoff_Zigbee_3.0_USB_Dongle_Plus...";
      };

      port = mkOption {
        type = types.port;
        default = 8080;
        description = "Zigbee2MQTT frontend port";
      };
    };

    nodered = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Node-RED";
      };

      dataDir = mkOption {
        type = types.path;
        default = "/var/lib/nodered";
        description = "Directory for Node-RED data";
      };

      port = mkOption {
        type = types.port;
        default = 1880;
        description = "Node-RED web interface port";
      };
    };
  };

  # TODO check
  config = mkIf cfg.enable {
    topology.self.services = {
      home-assistant = {
        name = "Home Assistant";
        info = lib.mkForce "Home Automation";
        details.listen.text = lib.mkForce domain;
      };
    };

    services.traefik = {
      dynamicConfigOptions = {
        http = {
          services.home-assistant.loadBalancer.servers = [
            {
              url = "http://[::]:8123";
            }
          ];

          routers.home-assistant = {
            entryPoints = ["websecure"];
            rule = "Host(`${domain}`)";
            service = "home-assistant";
            tls.certResolver = "letsencrypt";
            # middlewares = ["oidc-auth"]; Home Assistant don't support auth middleware
          };
        };
      };
    };

    systemd.tmpfiles.rules =
      [
        "d ${cfg.dataDir} 0755 root root -"
      ]
      ++ optionals cfg.matterServer.enable [
        "d ${cfg.matterServer.dataDir} 0755 root root -"
      ]
      ++ optionals cfg.mosquitto.enable [
        "d ${cfg.mosquitto.dataDir} 0755 root root -"
        "d ${cfg.mosquitto.dataDir}/config 0755 root root -"
        "d ${cfg.mosquitto.dataDir}/data 0755 root root -"
        "d ${cfg.mosquitto.dataDir}/log 0755 root root -"
      ]
      ++ optionals cfg.zigbee2mqtt.enable [
        "d ${cfg.zigbee2mqtt.dataDir} 0755 root root -"
      ]
      ++ optionals cfg.nodered.enable [
        "d ${cfg.nodered.dataDir} 0755 root root -"
      ];
    virtualisation.oci-containers = {
      backend = "docker";
      containers = {
        homeassistant = {
          image = "ghcr.io/home-assistant/home-assistant:stable";
          autoStart = true;

          volumes = [
            "${cfg.dataDir}:/config"
          ];

          environment = {
            TZ = cfg.timezone;
          };

          ports = [
            "${toString cfg.port}:8123"
          ];

          extraOptions =
            [
              "--network=host"
              "--privileged"
            ]
            ++ (map (dev: "--device=${dev}") (cfg.usbDevices ++ cfg.extraDevices));
        };
        matter-server = optionalAttrs cfg.matterServer.enable {
          image = "ghcr.io/home-assistant-libs/python-matter-server:stable";
          autoStart = true;

          volumes = [
            "${cfg.matterServer.dataDir}:/data"
            "/run/dbus:/run/dbus:ro"
          ];

          ports = [
            "${toString cfg.matterServer.port}:5580"
          ];

          extraOptions = [
            "--network=host"
          ];
        };

        # mosquitto = optionalAttrs cfg.mosquitto.enable {
        #   image = "eclipse-mosquitto:latest";
        #   autoStart = true;

        #   volumes = [
        #     "${cfg.mosquitto.dataDir}/config:/mosquitto/config"
        #     "${cfg.mosquitto.dataDir}/data:/mosquitto/data"
        #     "${cfg.mosquitto.dataDir}/log:/mosquitto/log"
        #   ];

        #   ports = [
        #     "${toString cfg.mosquitto.port}:1883"
        #     "${toString cfg.mosquitto.websocketPort}:9001"
        #   ];

        #   extraOptions = [
        #     "--user=1883:1883"
        #   ];
        # };

        # zigbee2mqtt = optionalAttrs cfg.zigbee2mqtt.enable {
        #   image = "koenkk/zigbee2mqtt:latest";
        #   autoStart = true;

        #   volumes = [
        #     "${cfg.zigbee2mqtt.dataDir}:/app/data"
        #     "/run/udev:/run/udev:ro"
        #   ];

        #   environment = {
        #     TZ = cfg.timezone;
        #   };

        #   ports = [
        #     "${toString cfg.zigbee2mqtt.port}:8080"
        #   ];

        #   extraOptions = [
        #     "--device=${cfg.zigbee2mqtt.device}"
        #   ];
        # };

        # nodered = optionalAttrs cfg.nodered.enable {
        #   image = "nodered/node-red:latest";
        #   autoStart = true;

        #   volumes = [
        #     "${cfg.nodered.dataDir}:/data"
        #   ];

        #   environment = {
        #     TZ = cfg.timezone;
        #   };

        #   ports = [
        #     "${toString cfg.nodered.port}:1880"
        #   ];
        # };
      };
    };

    services.udev.extraRules = ''
      # Allow access to USB serial devices
      SUBSYSTEM=="tty", ATTRS{idVendor}=="*", MODE="0666"
      SUBSYSTEM=="usb", ATTRS{idVendor}=="*", MODE="0666"
    '';

    # Ensure user has access to dialout group for serial devices
    users.groups.dialout = {};
  };
}
