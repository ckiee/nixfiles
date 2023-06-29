{ sources, lib, config, pkgs, ... }@margs:

with builtins;
with lib;

let
  cfg = config.cookie.services.ckiesite;
  util = import ../util.nix margs;
  port = "18592";

  inherit (sources) spectrogram-web abandoned-projects;
  inherit (pkgs.cookie) ckiesite;
  # TODO: oops broke all of these while moving to the non-static site
  # topLevelLinks = map (name: {
  #   name = name;
  #   path = ckiesite + (/. + name);
  # }) (attrNames (readDir "${ckiesite}"));
  # webroot = pkgs.linkFarm "webroot" ([
  #   {
  #     name = "spectrogram";
  #     path = spectrogram-web;
  #   }
  #   {
  #     name = "abandoned-projects";
  #     path = abandoned-projects + "/src";
  #   }
  # ] ++ topLevelLinks);

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

  config = mkIf cfg.enable (mkMerge [
    (util.mkService "ckiesite" {
      home = "/var/lib/ckiesite";
      description = "site of cookie";
      script = let bin = pkgs.cookie.ckiesite.defaultPackage.${pkgs.stdenv.hostPlatform.system};
      in ''
        exec ${bin}/bin/site --cache-org -p ${port} ${./data/org} ${./data/static}
      '';
    })
    {
      cookie.services.nginx.enable = true;

      services.nginx = {
        virtualHosts."${cfg.host}" = {
          locations."/".proxyPass = "http://127.0.0.1:${port}";
          extraConfig = ''
            rewrite ^/owobot$ https://discord.com/oauth2/authorize?client_id=731874934543876158&permissions=536895488&scope=bot permanent;
            access_log /var/log/nginx/ckiesite.access.log;
          '';
        };
      };
      cookie.services.prometheus.nginx-vhosts = [ "ckiesite" ];
    }
  ]);
}
