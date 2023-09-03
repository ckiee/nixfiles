{ lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.daiko;
  util = import ./util.nix margs;
in with lib; {
  options.cookie.services.daiko = {
    enable = mkEnableOption "daiko discord bot";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/daiko";
      description = "path to service home directory";
    };
    host = mkOption {
      type = types.str;
      default = "daiko.tailnet.ckie.dev";
      description = "nginx vhost";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "daiko" {
      home = cfg.folder;
      description = "daiko, the crappy assistant";
      secrets.config = {
        source = "./secrets/daiko.json";
        dest = "${cfg.folder}/config.json";
        permissions = "0400";
      };
      script = let bin = pkgs.cookie.daiko;
      in ''
        export WEB_PORT=3845
        exec ${bin}/bin/daiko
      '';
    })
    {
      services.nginx = {
        virtualHosts.${cfg.host} = {
          locations."/" = {
            proxyPass =
              "http://127.0.0.1:3845";
          };
          extraConfig = ''
            access_log /var/log/nginx/daiko.access.log;
          '';
        };
      };
      cookie.services.prometheus.nginx-vhosts = [ "daiko" ];

      cookie.restic.paths = [ "/var/lib/daiko/store.json" ];
    }
  ]);
}
