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
    paths = mkOption {
      type = types.listOf types.str;
      description = "The paths to back up";
      default = [ ];
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

    services.restic.backups = {
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

        rcloneConfigFile = sec.rclone-config.dest;
        repository = "rclone:gdrive:${host}";
        # timerConfig defualts to daily
        # user        defaults to root
      };
    };
  };
}
