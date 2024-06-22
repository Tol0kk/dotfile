{ self, ... }@inputs:
username: nixpkgs: system:

let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = (import ./overlay.nix { inherit inputs self; });
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
inputs.home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    inputs.stylix.homeManagerModules.stylix
    inputs.sops-nix.homeManagerModules.sops
    "${self}/Home/${username}/home.nix"
    globalConfig
  ] ++ home_modules;
  extraSpecialArgs = {
    inherit
      self
      inputs
      username
      color
      ;
  };
}
