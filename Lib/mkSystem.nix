{ self, ... } @ inputs: hostname: nixpkgs: system:
nixpkgs.lib.nixosSystem (
  let
    configuration = "${self}/Host/${hostname}/configuration.nix";
    hardware = "${self}/Host/${hostname}/hardware.nix";
    SelectedModules = "${self}/Host/${hostname}/modules.nix";
    modules = "${self}/Host/modules";
    overlays = (import ./overlay.nix { inherit inputs self;});

    pkgs = import nixpkgs {
      inherit system overlays;
      config = {
        allowUnsupportedSystem = false;
        allowBroken = false;
        allowUnfree = true;
        experimental-features = "nix-command flakes";
        keep-derivations = true;
        keep-outputs = true;
        config.packageOverrides = pkgs: { steam = pkgs.steam.override { extraPkgs = pkgs: with pkgs; [ libgdiplus keyutils libkrb5 libpng libpulseaudio libvorbis stdenv.cc.cc.lib xorg.libXcursor xorg.libXi xorg.libXinerama xorg.libXScrnSaver ]; }; };
      };
    };


    globalConfig = {
      boot.tmp.cleanOnBoot = true;
      networking.hostName = hostname;
      environment.systemPackages = with pkgs; [
        pfetch
        neovim
        home-manager
      ];
      documentation.man = {
        enable = true;
        generateCaches = true;
      };
    };
  in
  {
    inherit system pkgs;
    specialArgs = { inherit inputs self; };
    modules =
      [
        globalConfig
        configuration
        hardware
        modules
        SelectedModules
      ]
      # ++ __attrValues self.nixosModules
    ;
  }
)
