{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.hedgedoc;

in with lib; {
  options.cookie.services.hedgedoc = {
    enable = mkEnableOption "HedgeDoc";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
      default = "pad.pupc.at";
    };
  };

  config = mkIf cfg.enable {
    systemd.services.hedgedoc.after = [ "postgresql.service" ];

    # (ssh) ckie@flowe ~ -> sudo cp /run/hedgedoc/config.json /tmp/
    # (ssh) ckie@flowe ~ -> sudo chmod 444 /tmp/config.json
    # (ssh) ckie@flowe ~ -> sudo -u hedgedoc NODE_ENV=production CMD_CONFIG_FILE=/tmp/config.json /nix/store/vqv3dblqx76k185jg4ym5i3dz196lv19-nodejs-20.18.1/bin/node /nix/store/x00v8pqc4iy68b7kcvii5qhf97rxs424-hedgedoc-1.10.0/share/hedgedoc/bin/manage_users --add mei@puppycat.house --pass awawa
    services.hedgedoc = {
      enable = true;
      settings = {
        db = {
          dialect = "postgres";
          user = "hedgedoc";
          host = "/run/postgresql";
          database = "hedgedoc";
        };
        domain = cfg.host;
        allowOrigin = [ cfg.host ];
        protocolUseSSL = true;
        port = 29581;
        allowAnonymous = false;
      };
    };

    cookie.services.postgres = {
      enable = true;
      comb.hedgedoc = { ensureDBOwnership = true; };
    };

    cookie.services.nginx.enable = true;
    cookie.services.prometheus.nginx-vhosts = [ "hedgedoc" ];
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = {
        proxyPass = "http://localhost:29581";
        extraConfig = ''
          access_log /var/log/nginx/hedgedoc.access.log;
        '';
      };
    };
  };
}
