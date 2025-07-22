{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.transmission;

in with lib; {
  options.cookie.services.transmission = {
    enable = mkEnableOption "transmission";
    host = mkOption {
      type = types.str;
      default = "transm.tailnet.ckie.dev";
      description = "Nginx vhost";
    };
  };

  config = mkIf cfg.enable {
    # service
    services.transmission = {
      enable = true;
      package = pkgs.transmission_4;
      openPeerPorts = true;
      settings = {
        rpc-host-whitelist = "${cfg.host}";
        rpc-host-whitelist-enabled = true;
        umask = 7; # ug=rwx,o=---
        peer-port = 48952;
        watch-dir-enabled = true;
        speed-limit-down-enabled = true;
        speed-limit-up-enabled = true;
        speed-limit-down = 10000; # 10MB/s
        speed-limit-up = 10000; # 10MB/s
      };
      downloadDirPermissions = "770";
    };
    cookie.user.extraGroups = [ "transmission" ];

    # dont wanna bother updating all the paths so lets just..
    fileSystems."/var/lib/transmission" = {
      device = "/mnt/chonk/transmission";
      options = [ "bind" ];
    };

    # proxy
    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "transmission" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = { proxyPass = "http://127.0.0.1:9091"; };

      extraConfig = ''
        access_log /var/log/nginx/transmission.access.log;
      '';
    };
    # get tls cert
    cookie.tailnet-certs.client = rec {
      enable = true;
      hosts = singleton cfg.host;
    };
  };
}
