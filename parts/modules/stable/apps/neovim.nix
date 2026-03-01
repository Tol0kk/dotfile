{
  flake.nixosModules.neovim =
    {
      pkgs,
      lib,
      libCustom,
      config,
      inputs,
      self,
      ...
    }:
    {
      imports = [ self.nixosModules.neovim-minimal ];
      programs.nvf.settings = lib.mkDefault (
        (import "${self}/packages/neovim/config" {
          inherit lib;
          isMinimal = false;
        }).config
      );
    };

  flake.nixosModules.neovim-minimal =
    {
      pkgs,
      lib,
      libCustom,
      config,
      inputs,
      self,
      ...
    }:
    {
      imports = [ inputs.nvf.nixosModules.default ];
      config = {
        programs.nvf = {
          enable = true;
          enableManpages = true;
          settings = (
            (import "${self}/packages/neovim/config" {
              inherit lib;
              isMinimal = true;
            }).config
          );
        };

        environment.systemPackages = [ pkgs.neovim ];
      };
    };
}
