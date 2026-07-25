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

```sh
sudo rkdeveloptool ld
> DevNo=1	Vid=0x2207,Pid=0x350b,LocationID=303	Maskrom
```

Flash spi loader

```sh
sudo rkdeveloptool db rk3588_spl_loader_v1.15.113.bin
> Downloading bootloader succeeded.
```

Flash bios/bootloader

```sh
sudo rkdeveloptool wl 0 rock-5b-spi-image-gd1cf491-20240523.img
Write LBA from file (100%)
```

Reset Device

```sh
sudo rkdeveloptool rd
Reset Device OK.
```

# Rock 5B Documentation

https://docs.radxa.com/en/rock5/rock5b/hardware-design/hardware-interface?versions=ROCK+5B



# Disko install

> ![WRNING] Only work on the same architecture
> You can't **disko-install** a disk that don't target the same architecture than the host archicture.

This section describe how to install diretly on a mounted disk with credential setup direclty

- Generate/Create `configuration.nix`  
- Generate/Create `disko.nix`  
  - use disk id for drives
- Generate/Create `hardware.nix`  
- Generate/Create `default.nix`  
- Generate credential for new host 
  ```sh
  mkdir -p /tmp/host-keys/etc/ssh
  ssh-keygen -t ed25519 -N "" -C "myhost" \
    -f /tmp/host-keys/etc/ssh/ssh_host_ed25519_key
  chmod 600 /tmp/host-keys/etc/ssh/ssh_host_ed25519_key
  ```
- Generate Age Key
  ```sh
  cat /tmp/host-keys/etc/ssh/ssh_host_ed25519_key.pub | nix run nixpkgs#ssh-to-age
  ```
- Add age key to .sops.yaml
- Use age keys for your new hosts secrets.yaml
- Update keys 
  ```sh
  nix run nixpkgs#sops -- updatekeys secrets/secrets.yaml
  ```
- Install on disk 
  ```sh
  sudo nix run 'github:nix-community/disko/latest#disko-install' -- \
    --write-efi-boot-entries \
    --flake '.#olympus' \
    --disk main /dev/disk/by-id/wwn-0x500a0751e9a78849 \
    --extra-files /tmp/host-keys/etc/ssh/ssh_host_ed25519_key /etc/ssh/ssh_host_ed25519_key \
    --extra-files /tmp/host-keys/etc/ssh/ssh_host_ed25519_key.pub /etc/ssh/ssh_host_ed25519_key.pub
  ```
> ![NOTE]
> You can find disk id with  `ls -l /dev/disk/by-id/ | grep -v part` when mounted
> Those ids are immutable
