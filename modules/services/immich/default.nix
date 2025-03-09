{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.immich;

in with lib; {
  options.cookie.services.immich = {
    enable = mkEnableOption "immich photogallery";
    host = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "host for the web interface";
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings = {
      immich = {
        "${config.services.immich.mediaLocation}" = rec {
          d = {
            user = "ckie";
            group = "immich";
            mode = "0770";
          };
          e = mkForce d;
        };
      };
    };
    cookie.restic.paths = [ config.services.immich.mediaLocation ];

    services.immich = {
      enable = true;
      mediaLocation = "/mnt/chonk/immich";
      host = "localhost";
      port = 2283;
      settings = { server.externalDomain = "https://${cfg.host}"; };
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "immich" ];
    # for LAN immich sync, we rely on the fact that it happens to serve this record first:
    # (ssh) ckie@pansear ~ -> dog immich.tailnet.ckie.dev
    # A immich.tailnet.ckie.dev. 2m00s   192.168.0.8
    # A immich.tailnet.ckie.dev. 2m00s   100.120.191.17
    # ...and use pansear as the dns server for the iphone
    cookie.services.coredns.extraHosts = "192.168.0.8 ${cfg.host}";
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://localhost:2283";
        proxyWebsockets = true;
        extraConfig = ''
          access_log /var/log/nginx/immich.access.log;
          proxy_send_timeout 3600;
          client_max_body_size 10G;
        '';
      };
    };
  };
}
