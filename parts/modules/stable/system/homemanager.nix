{ inputs, ... }:
{
  flake.nixosModules.homemanager =
    {
      hostMetaOptions,
      pkgs-unstable,
      pkgs-stable,
      libs,
      ...
    }:
    {
      imports = [
        inputs.home-manager-unstable.nixosModules.home-manager
      ];

      # home-manager.useGlobalPkgs = true;
      home-manager.useUserPackages = true;
      home-manager.extraSpecialArgs = {
        inherit hostMetaOptions pkgs-unstable pkgs-stable;
      }
      // hostMetaOptions
      // libs;
    };

  flake.homeModules.homemanager =
    {
      hostMetaOptions,
      config,
      lib,
      ...
    }:
    {
      config = {
        home.stateVersion = hostMetaOptions.stateVersion;
        programs.home-manager.enable = true;
      };

      options.dotfiles = lib.mkOption {
        type = lib.types.path;
        apply = toString;
        default = "${config.home.homeDirectory}/.config/nixos";
        example = "${config.home.homeDirectory}/.config/nixos";
        description = "Location of the dotfiles working copy";
      };
    };
}
