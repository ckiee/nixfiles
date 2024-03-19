{ config, lib, pkgs, ... }:
with lib;
let cfg = config.cookie.services.mailserver;
in {
  config = mkIf cfg.enable {
    # https://nixos-mailserver.readthedocs.io/en/latest/add-roundcube.html
    services.roundcube = {
      enable = true;
      # this is the url of the vhost, not necessarily the same as the fqdn of
      # the mailserver
      hostName = "mx.ckie.dev";
      extraConfig = ''
        # starttls needed for authentication, so the fqdn required to match
        # the certificate
        $config['smtp_host'] = "tls://${config.mailserver.fqdn}";
        $config['smtp_user'] = "%u";
        $config['smtp_pass'] = "%p";
      '';
    };

    services.nginx.virtualHosts."mx.ckie.dev".enableACME =
      mkForce false; # from the nixos module, now handled by our acme module

    cookie.services.nginx.enable = true;
  };
}
