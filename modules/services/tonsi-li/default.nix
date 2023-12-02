{ lib, config, pkgs, ... }:

with lib;

let cfg = config.cookie.services.tonsi-li;
in {
  options.cookie.services.tonsi-li = {
    enable = mkEnableOption "tonsi-li";
    host = mkOption {
      type = types.str;
      description = "Host for web interface";
      default = "tonsi.li";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    # TODO: backend? blablala
    {
      cookie.services.nginx.enable = true;
      services.nginx = {
        virtualHosts."${cfg.host}" = {
          locations."/".root = "${pkgs.cookie.tonsi-li}/static";
          extraConfig = ''
            access_log /var/log/nginx/tonsi-li.access.log;
          '';
        };
      };
      cookie.services.prometheus.nginx-vhosts = [ "tonsi-li" ];
    }
  ]);
}
