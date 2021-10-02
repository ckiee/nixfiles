{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.headscale;

in with lib; {
  options.cookie.services.headscale = {
    enable = mkEnableOption "Enables the Headscale daemon";
    host = mkOption {
      type = types.str;
      description = "host for the web interface";
    };
    acmeHost = mkOption {
      type = types.str;
      description = "base host for acme";
      default = cfg.host;
    };
  };

  config = mkIf cfg.enable {
    services.headscale = {
      enable = true;
      publicURL = "https://${cfg.host}";
      listenAddress = "127.0.0.1:4329";

      tlsCertificatePath = "/var/lib/headscale/acme/cert.pem";
      tlsKeyPath = "/var/lib/headscale/acme/key.pem";
    };

    cookie.bindfs.headscale = {
      source = "/var/lib/acme/${cfg.acmeHost}";
      dest = "/var/lib/headscale/acme";
      overlay = false;
      args = "-u headscale -g headscale -p 0400,u+D";
      wantedBy = [ "headscale.service" ];
    };

    cookie.services.nginx.enable = true; # firewall & recommended defaults
    services.nginx.virtualHosts.${cfg.host} = {
      locations."/" = { proxyPass = "http://127.0.0.1:4329"; };
    };
  };
}
