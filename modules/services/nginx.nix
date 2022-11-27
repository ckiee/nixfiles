{ lib, config, pkgs, ... }:

let cfg = config.cookie.services.nginx;

in with lib; {
  options.cookie.services.nginx = {
    enable = mkEnableOption "Enables nginx service";
  };

  config = mkIf cfg.enable {
    services.nginx = {
      enable = true;
      enableReload = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;
      appendHttpConfig = ''
        add_header Permissions-Policy "interest-cohort=()";
      '';
    };

    systemd.services.nginx-config-reload.after =
      [ "coredns.service" "dns-hosts-poller.service" ];

    # TODO: remove soon, probably. there's a rule like this in nixpkgs now.
    services.logrotate = {
      enable = true;
      paths.nginx = {
        path = "/var/log/nginx/*.log";
        user = config.services.nginx.user;
        group = config.services.nginx.group;
        frequency = "monthly";
        keep = 0;
      };
    };

    networking.firewall.allowedTCPPorts = [ 443 80 ];
  };
}
