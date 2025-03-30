{ lib, config, pkgs, ... }:

with lib;
with builtins;

let
  cfg = config.cookie.restic;
  sec = config.cookie.secrets;
  host = config.networking.hostName;
  rcloneEntrypoint =
    if config.networking.hostName == "pansear" then "main-norecurs" else "main";
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
      restic-password = {
        # FIXME: this is also really ugly. we're just backing up more personal things
        # on these machines so we don't want to use the same key as the other ones.
        source = if elem config.networking.hostName [
          # It's important to keep all the old keys, as they're used for various one-shot backups.
          "cookiemonster"
          "thonkcookie"
          # pansear is implied (TODO: what does this mean??)
        ] then
          "./secrets/restic-password-desktop"
        else
          "./secrets/restic-password-server";
        owner = "root";
        group = "root";
        permissions = "0400";
      };
      rclone-config = {
        source = "./secrets/rclone.cfg";
        owner = "root";
        group = "root";
        permissions = "0400";
      };
    };

    services.restic.backups = rec {
      main = {
        initialize = true;
        passwordFile = sec.restic-password.dest;
        inherit (cfg) paths;
        pruneOpts = [
          "--keep-last 5"
          "--keep-daily 7"
          "--keep-weekly 5"
          "--keep-monthly 12"
          "--keep-yearly 75"
        ];
        # TODO: remove me and make sure backups still work
        extraBackupArgs = [
          "--exclude-file ${
            pkgs.writeText "restic-exclude-file"
            (concatStringsSep "\n" cfg.excludePaths)
          }"
        ];
        timerConfig = {
          OnCalendar = "00:30";
          RandomizedDelaySec = "5h";
        };

        rcloneConfigFile = sec.rclone-config.dest;
        repository = "rclone:${rcloneEntrypoint}:${host}-fs";
        # timerConfig defaults to daily
        # user        defaults to root
      };

      mainPostgres = mkIf cfg.enablePostgres (main // {
        # Base this off the main job but provide a dummy path
        paths = [ "/this/should/not/exist" ];
        repository = "rclone:${rcloneEntrypoint}:${host}-postgres";
      });
    };

    systemd.services.restic-backups-main = {
      preStart = cfg.preJob;
      postStart = cfg.postJob;
    };

    # Override the backup command this service runs to instead dump Postgres
    systemd.services.restic-backups-mainPostgres.serviceConfig.ExecStart =
      mkIf cfg.enablePostgres (mkForce [
        "${(pkgs.writeShellScript "restic-backups-mainPostgres-ExecStart" ''
           set -o pipefail
          ${config.services.postgresql.package}/bin/pg_dumpall -U postgres | ${pkgs.restic}/bin/restic backup --stdin --stdin-filename postgres.sql
        '')}"
      ]);

    environment.systemPackages = singleton
      (pkgs.runCommandLocal "restic-wrapped" { } ''
        . ${pkgs.makeWrapper}/nix-support/setup-hook
        makeWrapper ${pkgs.restic}/bin/restic $out/bin/restic \
          --set RCLONE_CONFIG /run/keys/rclone-config \
          --set RESTIC_PASSWORD_FILE /run/keys/restic-password \
          --set RESTIC_REPOSITORY rclone:${rcloneEntrypoint}:${host}-fs
      '');
  };
}
