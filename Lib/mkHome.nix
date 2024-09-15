{ self, nixpkgs-stable, nixpkgs-unstable, ... }@inputs:
username: nixpkgs: system:

let
  overlays = (import ./overlay.nix { inherit inputs self; });
  pkgs = import nixpkgs {
    inherit system overlays;
    config.allowUnfree = true;
  };
  pkgs-unstable = import nixpkgs-unstable {
    inherit system overlays;
    config.allowUnfree = true;
  };
  pkgs-stable = import nixpkgs-stable {
    inherit system overlays;
    config.allowUnfree = true;
  };
  home_modules = (
    builtins.map (dir: "${self}/Modules/Home/" + dir) (
      builtins.attrNames (builtins.readDir "${self}/Modules/Home")
    )
  );
  globalConfig = {
    home.stateVersion = "24.05";
    home.username = username;
    home.homeDirectory = /home/${username};
    programs.home-manager.enable = true;
  };
  color = import ./color.nix { lib = pkgs.lib; };
in
inputs.home-manager-unstable.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    "${self}/Home/${username}/home.nix"
    globalConfig
  ] ++ home_modules;
  extraSpecialArgs = {
    inherit
      self
      inputs
      username
      color
      pkgs-stable
      pkgs-unstable
      ;
  };
}
