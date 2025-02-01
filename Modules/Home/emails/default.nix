{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.emails;
in {
  options.modules.emails = {
    enable = mkOption {
      description = "Enable emails client thunderbird";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    accounts.email.accounts.perso = {
      primary = true;
      address = "titouanledilavrec@gmail.com";
      realName = "Le Dilavrec Titouan";
      signature.showSignature = "append";
      signature.delimiter = "=================";
      signature.text = "Le Dilavrec Titouan";
      # thunderbird.enable = true;
      # TODO: need to setup smtp and imap options
    };

    accounts.email.accounts.etudiant = {
      primary = false;
      address = "titouanledilavrec@gmail.com";
      thunderbird.enable = true;
      realName = "Le Dilavrec Titouan";
      # TODO: need to setup smtp and imap options
    };

    programs.thunderbird = {
      enable = true;
      profiles = {
        # etudiant.isDefault = false;
        # perso.isDefault = true;
      };
    };
  };
}
