{ sources, lib, config, pkgs, util, ... }@margs:

with lib;

let cfg = config.cookie.devserv;
in {
  options.cookie.devserv = {
    enable = mkEnableOption "Exposes port 4142 (ck00) to clearnet";
    host = mkOption {
      type = types.str;
      description = "Host for web interface";
      default = "${config.networking.hostName}-dev.tailnet.ckie.dev";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.enable {
      ### nginx reverse proxy
      cookie.services.nginx.enable = true;
      cookie.services.prometheus.nginx-vhosts = [ "devserv" ];
      services.nginx.virtualHosts.${cfg.host} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:4142";
          proxyWebsockets = true;
        };

        extraConfig = ''
          access_log /var/log/nginx/devserv.access.log;
        '';
      };
      ### get tls cert
      cookie.tailnet-certs.client = rec {
        enable = true;
        hosts = singleton cfg.host;
        forward = hosts;
      };
    })
  ]);
}
