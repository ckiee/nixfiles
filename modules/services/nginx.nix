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
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      recommendedBrotliSettings = true; # this one is the most impressive for pupcat
      appendHttpConfig = ''
        add_header Permissions-Policy "interest-cohort=()";
        add_header X-Clacks-Overhead "polygon";
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
