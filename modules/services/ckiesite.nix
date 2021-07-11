{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.ckiesite;

in with lib; {
  options.cookie.services.ckiesite = {
    enable = mkEnableOption "Enables ckie.dev service";
    host = mkOption {
      type = types.str;
      default = "ckiesite.localhost";
      description = "the host. wow.";
      example = "ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = { root = "${pkgs.cookie.ckiesite}"; };
        extraConfig = ''
          access_log /var/log/nginx/ckiesite.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "ckiesite" ];
  };
}
