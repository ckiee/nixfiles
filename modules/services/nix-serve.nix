{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.nix-serve;

in with lib; {
  options.cookie.services.nix-serve = {
    enable =
      mkEnableOption "Enables the nix-serve binary-cache hosting service";
    # TODO Figure out how to do clients. There's cookie.binaryCaches in cache.nix but I don't like it.
    host = mkOption {
      type = types.str;
      description = "Nginx vhost";
    };
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    cookie.secrets.nix-serve-cache-priv = {
        source = "./secrets/nix-serve-cache.priv";
        owner = "nix-serve";
        group = "nix-serve";
        permissions = "0400";
        wantedBy = "nix-serve.service";
    };

    services.nix-serve = {
      enable = true;
      bindAddress = "127.0.0.1";
      port = 3248;
      secretKeyFile = config.cookie.secrets.nix-serve-cache-priv.dest;
    };

    services.nginx = {
      virtualHosts."${cfg.host}" = {
        locations."/" = {
          proxyPass =
            "http://localhost:${toString config.services.nix-serve.port}";
          extraConfig = ''
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          '';
        };
        extraConfig = ''
          access_log /var/log/nginx/nix-serve.access.log;
        '';
      };
    };
    cookie.services.prometheus.nginx-vhosts = [ "nix-serve" ];
  };
}
