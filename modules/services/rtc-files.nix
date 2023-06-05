{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.rtc-files;

in with lib; {
  options.cookie.services.rtc-files = {
    enable = mkEnableOption "Enables rtc-files service";
    # old-fqdn = mkOption {
    #   type = types.str;
    #   description = "old fqdn";
    # };
    new-fqdn = mkOption {
      type = types.str;
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
    cookie.restic.paths = singleton cfg.folder;

    cookie.bindfs.rtc-files = {
      source = cfg.folder;
      overlay = true;
      args = "-M ckie,nginx --chmod-ignore -p u=rwD";
    };

    services.nginx = {
      virtualHosts = {
        # "i.${cfg.old-fqdn}" = {
        #   locations."/" = { root = cfg.folder; };
        #   extraConfig = ''
        #     rewrite ^/$ $scheme://${cfg.old-fqdn} permanent;
        #     # Redirect everything under /ckiedev to the new host
        #     rewrite ^/ckiedev/(.*)$ $scheme://i.${cfg.new-fqdn}/$1 permanent;

        #     access_log /var/log/nginx/rtc-files.access.log;
        #   '';
        # };
        "i.${cfg.new-fqdn}" = {
          locations."/" = { root = cfg.folder + "/ckiedev"; };
          extraConfig = ''
            # Redirect ckie.dev root url (/) to new FQDN
            rewrite ^/$ $scheme://${cfg.new-fqdn} permanent;
            charset utf-8;

            access_log /var/log/nginx/ckie-files.access.log;
          '';
        };
      };
    };

    cookie.services.prometheus.nginx-vhosts = [ "ckie-files" "rtc-files" ];
  };
}
