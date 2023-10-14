{ pkgs, lib, config, ... }:
with lib;
let cfg = config.modules.git;

in {
  options.modules.git = {
    enable = mkOption {
      description = "Enable git";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      enable = true;
      userName = "Tol0kk";
      userEmail = "titouan.le.dilavrec@gmail.com";
      extraConfig = {
        init = { defaultBranch = "main"; };
      };

      signing.key = "7E71419D61969A2C";
      

      # TODO Setup sign commit
      # signing.signByDefault = true;
		  # signing.key = null;
    };
  };
}
