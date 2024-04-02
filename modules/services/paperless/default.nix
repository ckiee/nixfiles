{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.paperless;

in with lib; {
  options.cookie.services.paperless = {
    enable = mkEnableOption "the paperless service";
    host = mkOption {
      type = types.str;
      default = "paperless.ckie.dev";
      description = "The user-facing host";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.postgres = {
      enable = true;
      comb.paperless = { ensureDBOwnership = true; };
    };

    cookie.secrets = {
      paperless-admin-password = {
        source = "./secrets/paperless-admin-password";
        owner = "root";
        group = "root";
        permissions = "0400";
        wantedBy = "paperless-copy-password.service";
      };
    };

    services.paperless = {
      enable = true;
      passwordFile = config.cookie.secrets.paperless-admin-password.dest;
      settings = {
        PAPERLESS_CONSUMER_IGNORE_PATTERN = [ ".DS_STORE/*" "desktop.ini" ];
        PAPERLESS_DBHOST = "/run/postgresql";
        PAPERLESS_OCR_LANGUAGE = "heb+eng+pol";
        PAPERLESS_OCR_USER_ARGS = {
          optimize = 1;
          pdfa_image_compression = "lossless";
invalidate_digital_signatures = true;
        };
        PAPERLESS_URL = "https://${cfg.host}";
        PAPERLESS_TASK_WORKERS = 4;
      };
    };

    # allow upload over nautilus sftp..
    cookie.user.extraGroups = [ "paperless" ];

    services.nginx.virtualHosts.${cfg.host} = {
      extraConfig = ''
        client_max_body_size 512m;
      '';
      locations."/" = {
        proxyPass =
          "http://localhost:${toString config.services.paperless.port}";
      };
    };
  };
}
