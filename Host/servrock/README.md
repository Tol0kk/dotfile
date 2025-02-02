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

# Architecure

Cloudflare-tunnel for reverse proxy of important channel.

- forgejo:

  - Endpoint: git.tolok.org
  - Port: 3000
  - Local: False

- vaultwarden:

  - Endpoint: vaultwarden.tolok.org
  - Port:
  - Local: False

- Prometheus Node Exporter:

  - Endpoint: None
  - Port: 9000
  - Local: True

- Wireguard:

  - Endpoint: vpn.tolok.org
  - Port: 51820
  - Local: False

- SSO (Kanidm):

  - Endpoint: sso.tolok.org
  - Port: 8443
  - Local: False

- Uptime Kuma:

  - Endpoint: None
  - Port: 8000
  - Local: True

- Home Assitant:
  - Endpoint: None
  - Port: 8123
  - Local: True
