{ self, stable, ... }@inputs: username: nixpkgs: system: stateVersion:
let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = (import ./overlay.nix { inherit inputs self; });
  };
in
inputs.home-manager-stable.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    ../Home/${username}
    ../Home/modules
    {
      home.stateVersion = stateVersion;
      home.username = username;
      home.homeDirectory = /home/${username};
      # nixpkgs.overlays = (import ./overlay.nix { inherit inputs self; });
    }
    inputs.hyprland.homeManagerModules.default
    inputs.anyrun.homeManagerModules.default
    inputs.sops-nix.homeManagerModules.sops
  ];
  extraSpecialArgs = { inherit self inputs username; };
}
