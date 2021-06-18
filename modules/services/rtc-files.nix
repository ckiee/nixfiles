{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.rtc-files;

in with lib; {
  options.cookie.services.rtc-files = {
    enable = mkEnableOption "Enables rtc-files service";
    old-fqdn = mkOption {
      type = types.str;
      default = "ronthecookie.me";
      description = "old fqdn";
    };
    new-fqdn = mkOption {
      type = types.str;
      default = "ckie.dev";
      description = "new fqdn";
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
        mkdir -p ${cfg.folder}/ckiedev || true

        chmod -R 750 ${cfg.folder}
        chmod -R g+s ${cfg.folder}
        chown -R ckie:nginx ${cfg.folder}
      '';
    };

    services.nginx = {
      virtualHosts = {
        "i.${cfg.old-fqdn}" = {
          locations."/" = { root = cfg.folder; };
          extraConfig = ''
            rewrite ^/$ $scheme://${cfg.old-fqdn} permanent;
            # Redirect everything under /ckiedev to the new host
            rewrite ^/ckiedev/(.*)$ $scheme://i.${cfg.new-fqdn}/$1 permanent;

            access_log /var/log/nginx/rtc-files.access.log;
          '';
        };
        "i.${cfg.new-fqdn}" = {
          locations."/" = { root = cfg.folder + "/ckiedev"; };
          extraConfig = ''
            # Redirect ckie.dev root url (/) to new FQDN
            rewrite ^/$ $scheme://${cfg.new-fqdn} permanent;

            access_log /var/log/nginx/ckie-files.access.log;
          '';
        };
      };
    };

    cookie.services.prometheus.nginx-vhosts = [ "ckie-files" "rtc-files" ];
  };
}
