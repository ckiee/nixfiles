{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.redirect-farm;

in with lib; {
  options.cookie.services.redirect-farm = {
    enable = mkEnableOption "Enables the redirect-farm service";
    host = mkOption {
      type = types.str;
      default = "redirect-farm.localhost";
      description = "the host";
      example = "u.ronthecookie.me";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        extraConfig = ''
          ${readFile ../../secrets/redirect-farm}
          access_log /var/log/nginx/redirect-farm.access.log;
        '';
      };
      virtualHosts."znc.ronthecookie.me" =
        mkIf (config.networking.hostName == "bokkusu") {
          extraConfig = ''
            access_log /var/log/nginx/redirect-farm.access.log;
            return 301 $scheme://znc.ckie.dev$request_uri;
          '';
        };
    };

    cookie.services.prometheus.nginx-vhosts = [ "redirect-farm" ];
  };
}
