{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.backup;
in {
  options.modules.backup = {
    enable = mkOption {
      description = "Enable backups";
      type = types.bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    # Secrets used for encrypting local backup
    sops.secrets.resticLocalBackupPasswordFile = {
      sopsFile = ./secrets.yaml;
    };

    services.restic.backups = {
      localbackup = {
        exclude = [
          "/home/*/.cache"
          "/home/*/.cargo"
          "/home/*/.rustup"
          "/home/*/.var"
          "/home/*/.config"
          "/home/*/.cloudflared"
          "/home/*/.mozilla"
          "/home/*/.java"
          "/home/*/.npm"
          "/home/*/.rustup"
          "/home/*/.steam"
          "/home/*/.terraform.d"
          "/home/*/.themes"
          "/home/*/.tldrc"
          "/home/*/go"
          "/home/*/.vscode"
          "/home/*/.vscode-oss"
          "/home/*/.zen"
          "/home/*/.zen"
          "/home/*/.local"
          "/home/*/.local/share/Trash"
          "/home/*/.android/"
          "/home/*/Games"
          "*.tmp"
          "*.bak"
        ];
        extraBackupArgs = [
          # exclude a folder’s content if it contains the special CACHEDIR.TAG file
          "--cleanup-cache"
        ];
        initialize = true;
        passwordFile = "${config.sops.secrets.resticLocalBackupPasswordFile.path}";
        paths = [
          "/home"
        ];
        repository = "/backup";
        inhibitsSleep = true; # Prevents the system from sleeping while backing up.
        pruneOpts = [
          # Keep 7 snapshot for the last each day
          "--keep-daily 7"
          # Keep 5 snapshot for the last each week
          "--keep-weekly 5"
          # Keep 12 snapshot for the last each month
          "--keep-monthly 12"
          # Keep 75 snapsht for the last each year
          "--keep-yearly 75"
        ];
        backupPrepareCommand = ''
          notify-send 'Local Backup is Starting'

          # Create a temp backup for Prism Saves
          if [ -d /home/titouan/Games/Prism_instances ]; then
              rm -fr /home/titouan/Backups/Games/Prism_instances
              mkdir -p /home/titouan/Backups/Games/Prism_instances
              cp -r /home/titouan/Games/Prism_instances/* /home/titouan/Backups/Games/Prism_instances/.
          fi
        '';
        backupCleanupCommand = ''
          # Remove temp backups
          if [ -d /home/titouan/Games/Prism_instances ]; then
            rm -fr /home/titouan/Backups/Games/Prism_instances
          fi

          notify-send 'Local Backup has Finished'
        '';
      };
      # remotebackup = {
      #   extraOptions = [
      #     "sftp.command='ssh backup@host -i /etc/nixos/secrets/backup-private-key -s sftp'"
      #   ];
      #   passwordFile = "/etc/nixos/secrets/restic-password";
      #   paths = [
      #     "/home"
      #   ];
      #   repository = "sftp:backup@host:/backups/home";
      #   timerConfig = {
      #     OnCalendar = "00:05";
      #     RandomizedDelaySec = "5h";
      #   };
      # };
    };
  };
}
