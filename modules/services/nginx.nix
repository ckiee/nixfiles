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
      recommendedGzipSettings = false; # for a few weeks now (i think), 2024-10-15: *26 gzip filter failed to use preallocated memory: 350272 of 336176 while sending to client, client:
      recommendedProxySettings = true;
      appendHttpConfig = ''
        add_header Permissions-Policy "interest-cohort=()";
      '';
      virtualHosts._ = {
        locations."~ .*".return = "404";
        default = true;
        rejectSSL = true;
      };
      package = pkgs.nginxMainline;
    };

    systemd.services.nginx-config-reload.after =
      [ "coredns.service" "dns-hosts-poller.service" ];

    networking.firewall.allowedTCPPorts = [ 443 80 ];
  };
}
