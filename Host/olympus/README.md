# Install bootloader from PC.

https://wiki.radxa.com/Rock5/install/spi

## Download.

Download loader image from
https://dl.radxa.com/rock5/sw/images/loader/rock-5b/release/

Download radxa tool to flash

```sh
nix-shell -p rkdeveloptool
```

## Connection

- Hold silver button facing up.
- Connect the computer to the card. (USB cable)
- Relase the silver button

# Flash

Test if rock5b card detected.

```
sudo rkdeveloptool ld
> DevNo=1	Vid=0x2207,Pid=0x350b,LocationID=303	Maskrom
```

Flash spi loader

```
sudo rkdeveloptool db rk3588_spl_loader_v1.15.113.bin
> Downloading bootloader succeeded.
```

Flash bios/bootloader

```
sudo rkdeveloptool wl 0 rock-5b-spi-image-gd1cf491-20240523.img
Write LBA from file (100%)
```

Reset Device

```
sudo rkdeveloptool rd
Reset Device OK.
```

# Rock 5B Documentation

https://docs.radxa.com/en/rock5/rock5b/hardware-design/hardware-interface?versions=ROCK+5B

# Architecure

Cloudflare-tunnel for reverse proxy of important channel.

- forgejo:

  - Endpoint: git.tolok.org
  - Port:
    - HTTP: 12000 (Local)
    - HTTPS: 12443
    - SSH: 12222
  - Local: False

- vaultwarden:

  - Endpoint: vaultwarden.tolok.org
  - Port:
    - HTTP: 8222 (Local)
    - HTTPS: Tunnled
  - Local: False

- Prometheus Node Exporter:

  - Endpoint: None
  - Port:
    - HTTP: 9000
  - Local: True

- Wireguard:

  - Endpoint: vpn.tolok.org
  - Port: 51820
  - Local: False

- SSO (Kanidm):

  - Endpoint: sso.tolok.org
  - Port:
    - HTTPS: 10443
  - Local: False

- Uptime Kuma:

  - Endpoint: None
  - Port:
    - HTTP: 8000 (Blocked)
    - HTTPS: 8443
  - Local: True

- Home Assitant:

  - Endpoint: None
  - Port:
    - HTTP: 8123 (Blocked: TODO)
    - HTTPS: 7443
  - Local: True
  - TODOs:
    - Add Automation
    - Setup SSL

- ESP Home:

  - Test: TODO
  - Endpoint: None
  - Port:
    - HTTP: 11437 (Blocked)
  - Local: True

- Jellyfin:

  - Endpoint: media.tolok.org
  - Port:
    - HTTP: 8096
  - Local: False

- Jellyseerr:

  - Endpoint: jellyseerr.media.tolok.org
  - Port:
    - HTTP: 5055
  - Local: False

- Deluge:

  - Endpoint: deluge.media.tolok.org
  - Port:
    - HTTP: 8112
  - Local: False

- Sonarr:

  - Endpoint: sonarr.media.tolok.org
  - Port:
    - HTTP: 8989
  - Local: False

- Radarr:

  - Endpoint: radarr.media.tolok.org
  - Port:
    - HTTP: 7878
  - Local: False

- Readarr:

  - Endpoint: readarr.media.tolok.org
  - Port:
    - HTTP: 8787
  - Local: False

- Bazarr:

  - Endpoint: bazarr.media.tolok.org
  - Port:
    - HTTP: 6767
  - Local: False

- Lidarr:

  - Endpoint: lidarr.media.tolok.org
  - Port:
    - HTTP: 8686
  - Local: False

- Own Clound IS:

  - Endpoint: cloud.tolok.org
  - Port:
    - HTTP: 15000 (Blocked)
    - HTTPS: 15443
  - Local: False

- Grafana:
  - Endpoint: grafana.tolok.org
  - Port:
    - HTTP: 47726 (Blocked)
  - Local: False  # TODO make True
  