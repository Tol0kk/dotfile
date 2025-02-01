{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.emacs;
  myEmacs =
    (pkgs.emacs.override {
      # Use gtk3 instead of the default gtk2
      withGTK3 = true;
      withGTK2 = false;
    })
    .overrideAttrs (attrs: {
      # I don't want emacs.desktop file because I only use
      # emacsclient.
      postInstall =
        (attrs.postInstall or "")
        + ''
          rm $out/share/applications/emacs.desktop
        '';
    });
in {
  options.modules.emacs = {
    enable = mkOption {
      description = "Enable emacs";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    services.emacs.enable = true;
    services.emacs.package = pkgs.emacs29-pgtk;
  };
}
