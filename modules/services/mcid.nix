{ lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.mcid;
  util = import ./util.nix margs;
in with lib; {
  options.cookie.services.mcid = {
    enable = mkEnableOption "Enables daniel's thing";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/mcid";
      description = "path to service home directory";
    };
    webPort = mkOption {
      type = types.port;
      description = "Web port";
      default = 18234;
    };
    gamePort = mkOption {
      type = types.port;
      description = "Game port";
      default = 18235;
    };
    host = mkOption {
      type = types.str;
      description = "Host for web interface";
      default = "mcid.party";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "mcid" {
      home = cfg.folder;
      description = "mcid — daniel's thing";
      script = let bin = pkgs.cookie.mcid;
      in ''
        WEB_PORT=${toString cfg.webPort} MC_PORT=${
          toString cfg.gamePort
        } exec ${bin}/bin/mcid
      '';
    })
    {
      services.redis.servers.mcid = {
        enable = true;
      };

      networking.firewall.allowedTCPPorts = singleton cfg.gamePort;

      cookie.services.nginx.enable = true;
      services.nginx = {
        virtualHosts."${cfg.host}" = {
          locations."/" = { proxyPass = "http://127.0.0.1:${toString cfg.webPort}"; };
          extraConfig = ''
            access_log /var/log/nginx/mcid.access.log;
          '';
        };
      };
      cookie.services.prometheus.nginx-vhosts = [ "mcid" ];
    }
  ]);
}
