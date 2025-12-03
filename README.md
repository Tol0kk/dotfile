# My Ecosystem

In this repository you will find the configuration I daily-drive on my 3 machine + my smartphone.

# Topology

This is the topology of my network. Using [nix-topology](https://github.com/oddlama/nix-topology)

<img src="topology.svg" height="600" />

# What does it include ?

This configuration cover an ARM Server, a X86-64 Desktop, a X86-64 laptop and an ARM Smarphone (through [Nix-On-Droid](https://github.com/nix-community/nix-on-droid)).

- Fully decalrative Network configuration.
- Secrets managed with [sops-nix](https://github.com/Mic92/sops-nix).
- Neovim configuration with [NVF](https://github.com/NotAShelf/nvf)
- Separated Home-Manager
- Centralized Theming with [Stylix](https://github.com/danth/stylix)
- Modularized Configuration


# Install

- Disable secureboot
- Preprare usb stick with iso
- prepare usb stick with secrets
- boot usb stick with iso
- follow command
```sh
# 0.1. Connect to internet
# Ethernet or wifi (nmtui)

# 1. copy sevrets inside installer
mkdir usb && sudo mount /dev/sdX disk && cp disk/secretes.tar.gz . && tar xvf seretes.tar.gz

# 2. clone configuration
git clone git@gitthub.com:Tol0kk/dotfile.git .config/nixos

# 3. Format disks
sudo disko --mode destroy,format,mount ~/.config/nixos/systems/<sys>/disko.nix

# 4. Install nixos
sudo nixos-install --flake ~/.config/nixos#<sys>

# 5. Mouve config & secrets into new install
cp -r ~/.config/nixos /mnt/home/<user>/.
cp secrets.tar.gz /mnt/home/<user>/.

# 5. Enter new install
sudo nixos-enter --root /mnt

# 6. Change user password
passwd <user>

# 7. Change owner shipt of config
chmod <user>:users /home/<user> -R

# 8. Switch user
su <user>

# 9. unpack files
cd && tar xvf secrets.tar.gz && mv nixos .config/.

# 10. activate home manager
home-manager switch --flake .config/nixos
```

## custo miso Improvements
- fix terminial fonts when inside hyprland
- remove welcome screen for zen
- create install script for step 2,3,4 at least
