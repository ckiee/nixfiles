{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.nix-serve;

  # TODO Cas\ Where should we run this? Not on the same machine as sensitive stuff in case secrets leak.
  # drapion might work (and hopefully has better peering!) but is IO-limited.
in with lib; {
  options.cookie.services.nix-serve = {
    enable =
      mkEnableOption "Enables the nix-serve binary-cache hosting service";
    # TODO Figure out how to do clients. There's cookie.binaryCaches in cache.nix but I don't like it.
  };

  config = mkIf cfg.enable {
    cookie.services.nginx.enable = true;

    services.nix-serve = {
      enable = true;
      bindAddress = "127.0.0.1";
      port = 3248; # selected by keyboard mash
      secretKeyFile = "/var/lib/nix-serve/private";
    };

    # We generate the key on-machine since cookie.secrets has a higher chance of leaking out somehow.
    systemd.services.nix-serve = {
      preStart = ''
        if [ ! -f /var/lib/nix-serve/private ]; then
          # We don't create the folder here because systemd should,
          # and if it didn't we don't want to mess up FS permissions by doing it manually

          #                                                                key-name private-path public-path
          ${config.nix.package}/bin/nix-store --generate-binary-cache-key ckie-${config.networking.hostname} /var/lib/nix-serve/private /var/lib/nix-serve/public
        fi
      '';
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
