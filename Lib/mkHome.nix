{ self, stable, ... }@inputs: username: nixpkgs: system: stateVersion:
let
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
    overlays = (import ./overlay.nix { inherit inputs self; });
  };
  home_modules = (builtins.map (dir: "${self}/Modules/Home/" + dir)
    (builtins.attrNames (builtins.readDir "${self}/Modules/Home")));
  color = import ./color.nix {
    lib = pkgs.lib;
  };
in
inputs.home-manager-stable.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      home.stateVersion = stateVersion;
      home.username = username;
      home.homeDirectory = /home/${username};
      # nixpkgs.overlays = (import ./overlay.nix { inherit inputs self; });

      nix.registry = {
        MyTemplate = {
          from = {
            id = "MyTemplate";
            type = "indirect";
          };
          to = {
            path = "${self}";
            type = "path";
          };
        };
      };
    }
    inputs.hyprland.homeManagerModules.default
    inputs.anyrun.homeManagerModules.default
    inputs.sops-nix.homeManagerModules.sops
    "${self}/Home/${username}"
  ] ++ home_modules;

  extraSpecialArgs = {
    inherit self inputs username color;
  };
}
