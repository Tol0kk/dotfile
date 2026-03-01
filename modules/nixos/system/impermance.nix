# Improted
{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkOption
    assertMsg
    any
    unique
    mkIf
    mkEnableOption
    hasPrefix
    ;
  inherit (lib.types) listOf str;
  assertNoHomeDirs =
    paths:
    assert (assertMsg (!any (hasPrefix "/home") paths) "/home used in a root persist!");
    paths;
  cfg = config.modules.system.persist;
in
{
  options.modules.system = {
    persist = {
      enable = mkEnableOption "zfs event daemon";
      root = {
        directories = mkOption {
          type = listOf str;
          default = [ ];
          apply = assertNoHomeDirs;
          description = "Directories to persist in root filesystem";
        };
        files = mkOption {
          type = listOf str;
          default = [ ];
          apply = assertNoHomeDirs;
          description = "Files to persist in root filesystem";
        };
        cache = {
          directories = mkOption {
            type = listOf str;
            default = [ ];
            apply = assertNoHomeDirs;
            description = "Directories to persist, but not to snapshot";
          };
          files = mkOption {
            type = listOf str;
            default = [ ];
            apply = assertNoHomeDirs;
            description = "Files to persist, but not to snapshot";
          };
        };
      };
      home = {
        directories = mkOption {
          type = listOf str;
          default = [ ];
          description = "Directories to persist in home directory";
        };
        files = mkOption {
          type = listOf str;
          default = [ ];
          description = "Files to persist in home directory";
        };
        cache = {
          directories = mkOption {
            type = listOf str;
            default = [ ];
            description = "Directories to persist, but not to snapshot";
          };
          files = mkOption {
            type = listOf str;
            default = [ ];
            description = "Files to persist, but not to snapshot";
          };
        };
      };
    };
  };

  imports = [ inputs.impermanence.nixosModules.impermanence ];
  config = mkIf cfg.enable {
    # Clear /tmp
    boot.tmp.cleanOnBoot = true;

    environment.persistence = {
      "/persist" = {
        hideMounts = true;
        files = unique cfg.root.files;
        directories = unique (
          # optionals config.custom.hardware.wifi.enable [ "/etc/NetworkManager" ]
          [ ] ++ cfg.root.directories
        );
      };
    };
  };
}
