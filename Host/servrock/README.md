

# Install bootloader from PC.

https://wiki.radxa.com/Rock5/install/spi


## Download.


Download loader image from https://dl.radxa.com/rock5/sw/images/loader/rock-5b/release/

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

