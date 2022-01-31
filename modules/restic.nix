{ lib, config, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.cookie.restic;
  sec = config.cookie.secrets;
  host = config.networking.hostName;
in {
  options.cookie.restic = {
    enable = mkEnableOption "Enables Restic backup management";
    enablePostgres = mkEnableOption "Enables Postgres dump backup";
    paths = mkOption {
      type = types.listOf types.str;
      description = "The paths to backup";
      default = [ ];
    };
    excludePaths = mkOption {
      type = types.listOf types.str;
      description = "The paths to exclude from the backup";
      default = [ ];
    };

    preJob = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Shell commands executed before the backup has started.
      '';
    };

    postJob = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Shell commands executed after the backup has ended.
      '';
    };
  };

  config = mkIf (cfg.enable && ((length cfg.paths) > 0)) {
    cookie.secrets = {
      gdrive-password = {
        source = "./secrets/gdrive-password";
        owner = "root";
        group = "root";
        permissions = "0400";
      };
      rclone-config = {
        source = "./secrets/rclone-config";
        owner = "root";
        group = "root";
        permissions = "0400";
      };
    };

    services.restic.backups = rec {
      gdrive = {
        initialize = true;
        passwordFile = sec.gdrive-password.dest;
        inherit (cfg) paths;
        pruneOpts = [
          "--keep-last 5"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 75"
        ];
        extraBackupArgs = [
          "--exclude-file ${
            pkgs.writeText "restic-exclude-file"
            (concatStringsSep "\n" cfg.excludePaths)
          }"
        ];

        rcloneConfigFile = sec.rclone-config.dest;
        repository = "rclone:gdrive:${host}-fs";
        # timerConfig defaults to daily
        # user        defaults to root
      };

      gdrivePostgres = mkIf cfg.enablePostgres (gdrive // {
        # Base this off the main job but provide a dummy path
        paths = [ "/this/should/not/exist" ];
        repository = "rclone:gdrive:${host}-postgres";
      });
    };

    systemd.services.restic-backups-gdrive = {
      preStart = cfg.preJob;
      postStart = cfg.postJob;
    };

    # Override the backup command this service runs to instead dump Postgres
    systemd.services.restic-backups-gdrivePostgres.serviceConfig.ExecStart =
      mkIf cfg.enablePostgres (mkForce [
        "${(pkgs.writeShellScript "restic-backups-gdrivePostgres-ExecStart" ''
           set -o pipefail
          ${config.services.postgresql.package}/bin/pg_dumpall -U postgres | ${pkgs.restic}/bin/restic backup --cache-dir=%C/restic-backups-gdrivePostgres --stdin --stdin-filename postgres.sql
        '')}"
      ]);

    environment.systemPackages = singleton
      (pkgs.runCommandLocal "restic-wrapped" {} ''
        . ${pkgs.makeWrapper}/nix-support/setup-hook
        makeWrapper ${pkgs.restic}/bin/restic $out/bin/restic \
          --set RCLONE_CONFIG /run/keys/rclone-config \
          --set RESTIC_PASSWORD_FILE /run/keys/gdrive-password \
          --set RESTIC_REPOSITORY rclone:gdrive:${host}-fs
      '');
  };
}
