{ sources, lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.ckiesite;
  inherit (sources) spectrogram-web;
  spectrogramRoot = pkgs.linkFarm "nginx-spectrogram-root" [{
    name = "spectrogram";
    path = spectrogram-web;
  }];
in with lib; {
  options.cookie.services.ckiesite = {
    enable = mkEnableOption "Enables ckie.dev service";
    host = mkOption {
      type = types.str;
      default = "ckiesite.localhost";
      description = "the host. wow.";
      example = "ckie.dev";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations = {
          "/".root = "${pkgs.cookie.ckiesite}";
          "/spectrogram".root = "${spectrogramRoot}";
        };
        extraConfig = ''
          rewrite ^/owobot$ https://discord.com/oauth2/authorize?client_id=731874934543876158&permissions=536895488&scope=bot permanent;
          access_log /var/log/nginx/ckiesite.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "ckiesite" ];
  };
}
