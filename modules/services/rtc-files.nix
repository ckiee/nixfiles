{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.rtc-files;

in with lib; {
  options.cookie.services.rtc-files = {
    enable = mkEnableOption "Enables rtc-files service";
    host = mkOption {
      type = types.str;
      default = "devel.i.ronthecookie.me";
      description = "the host. wow.";
      example = "i.ronthecookie.me";
    };
    redirect = mkOption {
      type = types.str;
      default = "ronthecookie.me";
      description = "host to redirect / to";
    };
    folder = mkOption {
      type = types.str;
      default = "/var/lib/rtc-files";
      description = "path to service home directory";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    system.activationScripts = {
      rtc-files-mkdir.text = ''
        mkdir -p ${cfg.folder} || true

        # nginx writes, ron reads
        chmod 740 ${cfg.folder}
        chown ron:nginx ${cfg.folder}
      '';
    };

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = { root = cfg.folder; };
        extraConfig = ''
          rewrite ^/$ $scheme://${cfg.redirect} permanent;
          access_log /var/log/nginx/rtc-files.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "rtc-files" ];
  };
}
