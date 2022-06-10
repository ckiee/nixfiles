{ sources, lib, config, pkgs, ... }:

with builtins;
with lib;

let
  cfg = config.cookie.services.ckiesite;
  inherit (sources) spectrogram-web;
  inherit (pkgs.cookie) ckiesite;
  topLevelLinks = map (name: {
    name = name;
    path = ckiesite + (/. + name);
  }) (attrNames (readDir "${ckiesite}"));
  webroot = pkgs.linkFarm "webroot" ([{
    name = "spectrogram";
    path = spectrogram-web;
  }] ++ (builtins.trace topLevelLinks topLevelLinks));
in {
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
        locations = { "/".root = "${webroot}"; };
        extraConfig = ''
          rewrite ^/owobot$ https://discord.com/oauth2/authorize?client_id=731874934543876158&permissions=536895488&scope=bot permanent;
          access_log /var/log/nginx/ckiesite.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "ckiesite" ];
  };
}
