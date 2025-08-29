{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.navidrome;

in with lib; {
  options.cookie.services.navidrome = {
    enable = mkEnableOption "the navidrome service";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "navi.tailnet.ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    services.navidrome = {
      enable = true;
      settings.MusicFolder = "/home/ckie/Music/flat";
      user = "ckie";
    };

    systemd.tmpfiles.settings.navidromeDirs.${config.services.navidrome.settings.MusicFolder}.d =
      mkForce {
        mode = ":770";
        user = ":ckie";
        group = ":users";
      };

    systemd.services.navidrome.serviceConfig.ProtectHome = mkForce false;

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "navidrome" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://localhost:4533";
        extraConfig = ''
          access_log /var/log/nginx/navidrome.access.log;
        '';
      };
    };

    cookie.tailnet-certs.client = rec {
      enable = true;
      hosts = singleton cfg.host;
      forward = hosts;
    };

  };
}
