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
      virtualHosts._ = {
        locations."~ .*".return = "404";
        default = true;
        rejectSSL = true;
      };
    };

    systemd.services.nginx-config-reload.after =
      [ "coredns.service" "dns-hosts-poller.service" ];

    networking.firewall.allowedTCPPorts = [ 443 80 ];
  };
}
