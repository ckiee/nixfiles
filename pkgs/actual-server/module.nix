# partially modified too
# https://github.com/aldoborrero/mynixpkgs/blob/67a7db27330f85af19f3ce52ae06671e573968ea/modules/actual-server.nix#L7
{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.actual-server;
in {
  options.services.actual-server = {
    enable = lib.mkEnableOption "Actual Server";

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "localhost";
      description = "Hostname for the Actual Server";
    };

    port = lib.mkOption {
      type = lib.types.int;
      default = 5006;
      description = "Port on which the Actual Server should listen";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/actual-server";
      description = "Directory for user files";
    };

    upload = {
      fileSizeSyncLimitMB = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "File size limit in MB for synchronized files";
      };

      syncEncryptedFileSizeLimitMB = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "File size limit in MB for synchronized encrypted files";
      };

      fileSizeLimitMB = lib.mkOption {
        type = lib.types.nullOr lib.types.int;
        default = null;
        description = "File size limit in MB for file uploads";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.actual-server];

    systemd.services.actual-server = {
      description = "Actual Server";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        ExecStart = "${pkgs.actual-server}/bin/start-actual-server";
        Restart = "always";
        StateDirectory = "actual-server";
        DynamicUser = true;
        Environment = {
          # Set environment variables from configuration options here
          ACTUAL_HOSTNAME = cfg.hostname;
          ACTUAL_PORT = toString cfg.port;
          ACTUAL_USER_FILES = cfg.stateDir;
          # For uploads, set the respective environment variables.
          ACTUAL_UPLOAD_FILE_SYNC_SIZE_LIMIT_MB = toString (cfg.upload.fileSizeSyncLimitMB or "");
          ACTUAL_UPLOAD_SYNC_ENCRYPTED_FILE_SIZE_LIMIT_MB = toString (cfg.upload.syncEncryptedFileSizeLimitMB or "");
          ACTUAL_UPLOAD_FILE_SIZE_LIMIT_MB = toString (cfg.upload.fileSizeLimitMB or "");
        };
      };
    };
  };
}
