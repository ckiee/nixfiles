{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.changedetection;

in with lib; {
  options.cookie.services.changedetection = {
    enable = mkEnableOption "the changedetection.io service";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "chg.ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.secrets.changedetection = {
      source = "./secrets/changedetection.env";
      owner = "changedetection-io";
      group = "changedetection-io";
      permissions = "0400";
      wantedBy = "changedetection-io.service";
    };

    services.changedetection-io = {
      enable = true;
      port = 27312;
      baseURL = "https://${cfg.host}";
      behindProxy = true;
      environmentFile = config.cookie.secrets.changedetection.dest;
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "changedetection" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://127.0.0.1:27312";
        extraConfig = ''
          access_log /var/log/nginx/changedetection.access.log;
        '';
      };
    };
  };
}
