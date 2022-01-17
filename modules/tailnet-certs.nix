{ lib, config, pkgs, ... }:

let cfg = config.cookie.tailnet-certs;

in with lib; {
  options.cookie.tailnet-certs = {
    enableServer =
      mkEnableOption "Enables sharing of the *.tailnet TLS certificate";
    enableClient =
      mkEnableOption "Enables usage of the *.tailnet TLS certificate";
    host = mkOption {
      type = types.str;
      default = "tailnet.ckie.dev";
      description = "Full host to share";
    };
    serveHost = mkOption {
      type = types.str;
      default = "certs.tailnet.ckie.dev";
      description = "Full host to share";
    };
  };

  config = mkMerge [
    (mkIf (cfg.enableServer || cfg.enableClient) {
      cookie.services.coredns.extraHosts =
        "100.124.234.25 certs.tailnet.ckie.dev"; # TODO template
    })
    (mkIf cfg.enableServer {
      cookie.bindfs.tailnet-certs = {
        source = "/var/lib/acme/${cfg.host}";
        dest = "/var/lib/tailnet-certs";
        overlay = false;
        args = " -u nginx -g nginx -p 0400,u+X";
      };

      services.nginx.virtualHosts.${cfg.serveHost} = {
        forceSSL = true;
        useACMEHost = cfg.host;
        locations."/" = {
          root = "/var/lib/tailnet-certs";
          extraConfig = ''
            allow 100.64.0.0/10;
            deny all;
          '';
        };
      };
    })
    (mkIf cfg.enableClient {

    })
  ];
}
