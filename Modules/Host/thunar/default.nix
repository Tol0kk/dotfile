{ pkgs, lib, config, ... }:

with lib;
let
  cfg = config.modules.thunar;
in
{
  options.modules.thunar = {
    enable = mkOption {
      description = "Enable Thunar";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xfce.tumbler
    ];
    programs.thunar.enable = true;
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-dropbox-plugin
      thunar-media-tags-plugin
      thunar-archive-plugin
    ];
    systemd.services."thunar" = {
      enable = true;
      description = "Thunar daemon";
      after = [ "graphical-session-pre.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.xfce.thunar}/bin/thunar --daemon";
        Restart = "on-failure";
      };
    };
  };
}
