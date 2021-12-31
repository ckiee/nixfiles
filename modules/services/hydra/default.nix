{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.hydra;
  util = import ./util.nix { inherit lib config; };
in with lib; {
  options.cookie.services.hydra = {
    enable = mkEnableOption "Enables the hydra daemon";
    host = mkOption {
      type = types.str;
      default = "hydra.ckie.dev";
      description = "the host";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.postgres = {
      enable = true;
      comb.hydra = { };
    };

    services.hydra = {
      enable = true;
      dbi = "dbi:Pg:dbname=hydra;user=hydra;";
      hydraURL = "https://${cfg.host}";
      listenHost = "127.0.0.1";
      logo = ./logo.png;
      useSubstitutes = true;
      port = 1283;
      notificationSender = "hydra@ckie.dev";
      smtpHost = "localhost";
    };

    cookie.services.nginx.enable = true;
    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/".proxyPass = "http://127.0.0.1:1283";
        extraConfig = ''
          access_log /var/log/nginx/hydra.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "hydra" ];
  };
}
