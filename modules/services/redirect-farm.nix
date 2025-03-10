{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.redirect-farm;

in with lib; {
  options.cookie.services.redirect-farm = {
    enable = mkEnableOption "redirect-farm service";
    host = mkOption {
      type = types.str;
      default = "redirect-farm.localhost";
      description = "the host";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    cookie.secrets.redirect-farm = {
      source = "./secrets/redirect-farm";
      runtime = false;
    };

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        extraConfig = ''
          ${readFile ../../secrets/redirect-farm}
          access_log /var/log/nginx/redirect-farm.access.log;
        '';
      };
    };

    cookie.services.prometheus.nginx-vhosts = [ "redirect-farm" ];
  };
}
