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
      appendHttpConfig = ''
        add_header Permissions-Policy "interest-cohort=()";
      '';
    };
    networking.firewall.allowedTCPPorts = [ 443 80 ];
  };
}
