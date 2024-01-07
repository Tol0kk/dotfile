{ config, pkgs, self, inputs, ... }:

{
  modules = {
    bluetooth.enable = true;
    common.enable = true;
    fonts.enable = true;
    gaming.enable = true;
    nvidia.enable = true;
    nvidia.offload = {
      enable = true;
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    samba.enable = false;
    sddm.enable = true;
    udev.enableExtraRules = true;
  };

  # Enable networking
  networking.networkmanager.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    brave
    git
    zoxide
    btop
    lsd
    file
    kitty
    blender_4_0
    wpaperd
    wofi
    onagre
    vscodium-fhs
    rustup
    nixpkgs-fmt
    glib
    libgnomekbd
    cinnamon.nemo-fileroller
    cinnamon.nemo-with-extensions
    cinnamon.nemo-emblems
    cinnamon.folder-color-switcher
    polkit_gnome
    zathura
    ripgrep
    (callPackage "${self}/Pkgs/assetsPkgs" { })
    iperf # network benchmark
    xarchiver
    # ...
    # (vscode-with-extensions.override {
    #   vscode = vscodium;
    #   vscodeExtensions = with vscode-extensions; [
    #     llvm-vs-code-extensions.vscode-clangd
    #   ];
    # })

    inputs.mesa-demo.packages.${pkgs.system}.glxgears
    inputs.mesa-demo.packages.${pkgs.system}.glxinfo
    vulkan-tools
    unigine-heaven
  ];
  services.xserver.desktopManager.cinnamon.enable = true; # Try disabling, while keeping open in terminal true.
  services.cinnamon.apps.enable = false;
  hardware.pulseaudio.enable = false;
  services.xserver.desktopManager.cinnamon.extraGSettingsOverrides = ''
    [org.cinnamon.desktop.default-applications.terminal]
    exec='kitty'
  '';

  programs.firefox.enable = true;
  boot.supportedFilesystems = [ "ntfs" ];
  programs.starship.enable = true;
  programs.fish.enable = true;
  programs.hyprland.enable = true;
  programs.waybar.enable = true;
  services.gvfs.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [ thunar-archive-plugin thunar-volman ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
  sound.enable = true;
  sound.mediaKeys.enable = true;

  system.stateVersion = "23.11"; # Did you read the comment?
}
