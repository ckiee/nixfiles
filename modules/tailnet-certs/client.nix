{ nodes, lib, config, pkgs, ... }:

let
  cfg = config.cookie.tailnet-certs;
  hostname = config.networking.hostName;
in with lib;
with builtins; {
  config = mkIf cfg.client.enable {
    cookie.services.nginx.enable = true;

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
        mkRng > ${source}
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
  };
}
