{ nodes, lib, config, pkgs, ... }:

let cfg = config.cookie.tailnet-certs;

in with lib;
with builtins; {
  options.cookie.tailnet-certs = {
    enableServer =
      mkEnableOption "Enables sharing of the *.tailnet TLS certificate";
    client = mkOption {
      type = types.submodule {
        options = {
          enable =
            mkEnableOption "Enables usage of the *.tailnet TLS certificate";
          hosts = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "nginx vhosts to configure";
          };
        };
      };
      default = { enable = false; };
      description = "client options";
    };
    host = mkOption {
      type = types.str;
      default = "tailnet.ckie.dev";
      description = "Full host to share";
    };
    serveHost = mkOption {
      type = types.str;
      default = "certs.tailnet.ckie.dev";
      description = "Host to serve the certificates on";
    };
  };

  config = mkMerge [
    ({
      cookie.services.coredns.extraHosts = ''
        ${
          (head (attrValues (filterAttrs
            (_: host: host.config.cookie.tailnet-certs.enableServer)
            nodes))).config.cookie.machine-info.tailscaleIp
        } certs.tailnet.ckie.dev
        ${concatStringsSep "\n" (mapAttrsToList (name: h:
          concatMapStringsSep "\n" (vhost:
            "${
              h.config.cookie.machine-info.tailscaleIp or (throw
                "Missing tailscaleIp for ${name}")
            } ${vhost}") h.config.cookie.tailnet-certs.client.hosts) nodes)}
      '';
    })

    (mkIf cfg.enableServer {
      cookie.bindfs.tailnet-certs = {
        source = "/var/lib/acme/${cfg.host}";
        dest = "/var/lib/tailnet-certs";
        overlay = false;
        args = "-u nginx -g nginx -p 0400,u+D";
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
    (mkIf cfg.client.enable (mkMerge [{
      assertions = [{
        assertion = config.services.nginx.enable;
        message = "tailnet-certs client depends on Nginx";
      }];

      systemd.services.get-tailnet-certs = {
        description = "Fetches new certificates for *.${cfg.host}";
        startAt = "*-*-* 04:30:00"; # every day at 4:30am
        wantedBy = [ "nginx.service" ];
        after = [ "tailscaled.service" ]; # We do kinda need the network..

        script = ''
          mkdir /var/lib/tailnet-certs || true
          chown -R root:root /var/lib/tailnet-certs
          chmod -R 700 /var/lib/tailnet-certs
          for file in cert.pem chain.pem fullchain.pem full.pem key.pem; do
            ${pkgs.wget}/bin/wget -O /var/lib/tailnet-certs/"$file" 'https://${cfg.serveHost}/'"$file"
          done
        '';
      };

      # Something somewhere refuses to let the "nginx" user read anything
      # I refuse to debug that. Too fucking weird.
      cookie.bindfs.tailnet-certs = {
        source = "/var/lib/tailnet-certs";
        overlay = true;
        args = "-u nginx -g nginx -p 0400,u+D";
        wantedBy = [ "get-tailnet-certs.service" ];
      };

      systemd.services.nginx.serviceConfig.ReadOnlyPaths =
        [ "/var/lib/tailnet-certs" ];

      services.nginx.virtualHosts = mkMerge (map (e: {
        ${e} = {
          forceSSL = true;
          sslCertificate = "/var/lib/tailnet-certs/fullchain.pem";
          sslCertificateKey = "/var/lib/tailnet-certs/key.pem";
          sslTrustedCertificate = "/var/lib/tailnet-certs/chain.pem";
        };
      }) cfg.client.hosts);
    }]))
  ];
}
