{
  description = "My Nixos flake Configuration";
  inputs = {
+   # stable.url = "github:nixos/nixpkgs/nixos-23.05";
    # home-manager-stable.url = "github:nix-community/home-manager/release-23.05";
    stable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager-stable.url = "github:nix-community/home-manager";
    home-manager-stable.inputs.nixpkgs.follows = "stable";
    hyprland.url = "https://github.com/hyprwm/Hyprland/releases/download/v0.29.1/source-v0.29.1.tar.gz";
    prismlauncher.url = "github:PrismLauncher/PrismLauncher";
    anyrun.url = "github:Kirottu/anyrun";
    sops-nix.url = "github:Mic92/sops-nix";
    ags.url = "github:Aylur/ags";
    eww.url = "github:Tol0kk/eww";
  };
  outputs = { self, ... } @ inputs:
    {
      lib = import ./Lib inputs;
      nixosConfigurations = import ./Host inputs;
      homeConfigurations = import ./Home inputs;
      templates = import ./Template;
    };
}
