{ sources, lib, config, pkgs, util, ... }@margs:

with lib;

let cfg = config.cookie.devserv;
in {
  options.cookie.devserv = {
    enable = mkEnableOption "Exposes ports starting 4142 (ck00) to clearnet";
    hosts = mkOption {
      type = with types; listOf str;
      description = "Hostnames to expose";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enable {
      cookie.devserv.hosts =
        [ "${config.networking.hostName}-dev.tailnet.ckie.dev" ];
      ### nginx reverse proxy
      cookie.services.nginx.enable = true;
      cookie.services.prometheus.nginx-vhosts = [ "devserv" ];
      services.nginx.virtualHosts = mkMerge (imap0 (i: host: {
        ${host} = {
          locations."/" = {
            proxyPass = "http://127.0.0.1:${toString (4142 + i)}";
            proxyWebsockets = true;
            extraConfig = ''
              proxy_read_timeout 18000s;
              ${optionalString (host == "pupcat-dev.tailnet.ckie.dev")
              "proxy_set_header Origin http://$host;"}
            '';
          };

          extraConfig = ''
            access_log /var/log/nginx/devserv.access.log;
          '';
        };
      }) cfg.hosts);
      ### get tls cert
      cookie.tailnet-certs.client = {
        enable = true;
        hosts = cfg.hosts;
        forward = cfg.hosts;
      };
    })
  ]);
}
