{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.rtcme;

in with lib; {
  options.cookie.services.rtcme = {
    enable = mkEnableOption "Enables rtcme service";
    host = mkOption {
      type = types.str;
      default = "rtcme.localhost";
      description = "the host. wow.";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        globalRedirect = "ckie.dev";
        extraConfig = ''
          access_log /var/log/nginx/rtcme.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "rtcme" ];
  };
}
