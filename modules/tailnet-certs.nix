{ nodes, lib, config, pkgs, ... }:

let
  cfg = config.cookie.tailnet-certs;
  hostname = config.networking.hostName;
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
          forward = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description =
              "nginx vhosts to publicly expose by forwarding through the enableServer host";
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
            nodes))).config.cookie.state.tailscaleIp
        } certs.tailnet.ckie.dev
        ${concatStringsSep "\n" (mapAttrsToList (name: h:
          concatMapStringsSep "\n" (vhost:
            "${
              h.config.cookie.state.tailscaleIp or (throw
                "Missing tailscaleIp for ${name}")
            } ${vhost}") h.config.cookie.tailnet-certs.client.hosts) nodes)}
      '';
    })

    (mkIf cfg.enableServer (mkMerge [
      {
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
              auth_basic "tailnet-certs";
              auth_basic_user_file ${../secrets/tailnet-certs-htpasswd};
            '';
          };
        };
      }
      {
        systemd.services = rec {
          nginx = rec {
            wantedBy = [ "coredns.service" ];
            after = wantedBy;
          };
          nginx-config-reload = nginx;
        };

        cookie.services.prometheus.nginx-vhosts = [ "tailnet-certs-proxy" ];
        services.nginx.virtualHosts = mkMerge (map (vhost: ({
          ${vhost} = {
            forceSSL = true;
            useACMEHost = cfg.host;
            locations."/".proxyPass = "https://${vhost}";
            extraConfig = ''
              access_log /var/log/nginx/tailnet-certs-proxy.access.log;
            '';
          };
        })) (flatten
          (mapAttrsToList (_: h: h.config.cookie.tailnet-certs.client.forward)
            nodes)));
      }
    ]))

    (mkIf cfg.client.enable {
      assertions = [{
        assertion = config.services.nginx.enable;
        message = "tailnet-certs client depends on Nginx";
      }];

      systemd.services.get-tailnet-certs = mkIf (!cfg.enableServer) {
        description = "Fetches new certificates for *.${cfg.host}";
        startAt = "*-*-* 04:30:00"; # every day at 4:30am
        wantedBy = [ "nginx.service" ];
        before = [ "nginx.service" ];
        after = [
          "tailscaled.service"
          "coredns.service"
        ]; # We do kinda need the network..

        script = let
          pass = config.cookie.secrets.tailnet-certs-pw.dest;
          askpass = pkgs.writeShellScript "tailnet-certs-askpass" ''
            case "$1" in
              Username*)
                echo ${hostname}
              ;;
              Password*)
                cat ${pass}
              ;;
              *)
                exit 1
              ;;
            esac
          '';
        in ''
          mkdir /var/lib/tailnet-certs || true
          chown -R root:root /var/lib/tailnet-certs
          chmod -R 700 /var/lib/tailnet-certs
          for file in cert.pem chain.pem fullchain.pem full.pem key.pem; do
            ${pkgs.wget}/bin/wget \
                --retry-connrefused --tries 10 --waitretry 10 \
                -O /var/lib/tailnet-certs/"$file" --use-askpass=${askpass} \
                'https://${cfg.serveHost}/'"$file"
          done
        '';
      };

      # Something somewhere refuses to let the "nginx" user read anything
      # I refuse to debug that. Too fucking weird.
      cookie.bindfs.tailnet-certs = mkIf (!cfg.enableServer) {
        source = "/var/lib/tailnet-certs";
        overlay = true;
        args = "-u nginx -g nginx -p 0400,u+D";
        wantedBy = [ "get-tailnet-certs.service" ];
      };

      systemd.services.nginx.serviceConfig.ReadOnlyPaths =
        [ "/var/lib/tailnet-certs" ];

      # Prepare a password for the HTTP basicauth the certs service has.
      # FIXME: Not too happy with this as old machines don't get automatically GC'd.
      cookie.secrets.tailnet-certs-pw = rec {
        source = "./secrets/tailnet-certs-${hostname}-pw";
        permissions = "0400";
        generateCommand = ''
          < /dev/urandom tr -dc '[a-z0-9A-Z@-^]' | head -c 255 > ${source}
          (
            htp_creat=""
            [ ! -e secrets/tailnet-certs-htpasswd ] && htp_creat="-c"
            cat ${source} | ${pkgs.apacheHttpd}/bin/htpasswd -iB $htp_creat secrets/tailnet-certs-htpasswd ${hostname}
          )
        '';
      };

      services.nginx.virtualHosts = mkMerge (map (e: {
        ${e} = {
          forceSSL = true;
          sslCertificate = "/var/lib/tailnet-certs/fullchain.pem";
          sslCertificateKey = "/var/lib/tailnet-certs/key.pem";
          sslTrustedCertificate = "/var/lib/tailnet-certs/chain.pem";
        };
      }) cfg.client.hosts);
    })
  ];
}
