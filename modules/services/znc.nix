{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.znc;

in with lib; {
  options.cookie.services.znc = {
    enable = mkEnableOption "Enables ZNC service";
    host = mkOption {
      type = types.str;
      default = "znc.localhost";
      description = "the host";
      example = "znc.ckie.dev";
    };
    acmeHost = mkOption {
      type = types.str;
      default = cfg.host;
      description = "the host the certificate is under";
    };
  };

  config = mkIf cfg.enable {
    # First, we turn ZNC on.
    services.znc = {
      enable = true;
      useLegacyConfig = false;
    };

    # ...and we let it through the firewall.
    networking.firewall.allowedTCPPorts = [ 6697 ];

    # We confide it with our precious certificate
    security.acme.certs.${cfg.acmeHost}.postRun =
      "cat {key,fullchain}.pem > /var/lib/znc/znc.pem";

    # We give it a medium which through to talk with it's users.
    cookie.services.nginx.enable = true;
    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = { proxyPass = "http://127.0.0.1:8572"; };
        extraConfig = ''
          access_log /var/log/nginx/znc.access.log;
        '';
      };
    };
    #
    cookie.services.prometheus.nginx-vhosts = [ "znc" ];
    cookie.restic.paths = [ "/var/lib/znc/moddata/log" ];
  };
}
