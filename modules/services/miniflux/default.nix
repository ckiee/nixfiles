{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.miniflux;

in with lib; {
  options.cookie.services.miniflux = {
    enable = mkEnableOption "miniflux reader";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "flux.pupc.at";
    };
  };

  config = mkIf cfg.enable {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "localhost:23849";
        CREATE_ADMIN = 0;
        BASE_URL = "https://${cfg.host}/";
      };
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "miniflux" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:23849";
        extraConfig = ''
          proxy_hide_header X-Frame-Options;
          add_header X-Frame-Options SAMEORIGIN always; # loosen miniflux req for my userscript
          access_log /var/log/nginx/miniflux.access.log;
        '';
      };
    };
  };
}
