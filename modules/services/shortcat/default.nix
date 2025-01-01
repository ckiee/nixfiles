{ lib, config, pkgs, ... }@margs:

with lib;

let
  cfg = config.cookie.services.shortcat;
  util = import ../util.nix margs;
in {
  options.cookie.services.shortcat = {
    enable = mkEnableOption "shortcat";
    host = mkOption {
      type = types.str;
      default = "pupc.at";
      description = "serve on?";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "shortcat" {
      description = "shortcat link shortener";
      script = ''
        mkdir -p yargs/build/locales
        ln -sf ${./en.json} yargs/build/locales/en.json

        bin=./shortcat
        [ -e $bin ] || bin=${../../../secrets/shortcat}

        export NODE_ENV=production
        exec $bin serve --db-path shortcat.db 28314
      '';
      path = with pkgs; [ bun ];
    })
    {
      services.nginx = {
        virtualHosts.${cfg.host} = {
          locations."/" = { proxyPass = "http://127.0.0.1:28314"; };
          extraConfig = ''
            access_log /var/log/nginx/shortcat.access.log;
          '';
        };
      };
      cookie.services.prometheus.nginx-vhosts = [ "shortcat" ];

      cookie.restic.paths = [ "/var/lib/shortcat/shortcat.db" ];

      cookie.bindfs.shortcat = {
        source = "/var/lib/shortcat";
        dest = "${config.cookie.user.home}/shortcat";
        overlay = false;
        args =
          "--create-for-user=shortcat --create-with-perms=0700 -u ckie -g users -p 0600,u+X";
      };
    }
  ]);
}
