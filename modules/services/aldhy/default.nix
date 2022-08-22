{ util, lib, config, pkgs, ... }@margs:

let
  cfg = config.cookie.services.aldhy;
  inherit (import ../util.nix margs) mkService mkCgi;
  inherit (util) mkRequiresScript;
in with lib; {
  options.cookie.services.aldhy = {
    enable = mkEnableOption "Enables the aldhy distributed nix evaluator";
    folder = mkOption {
      type = types.str;
      default = "/var/lib/aldhy";
      description = "path to service home directory";
    };
    port = mkOption {
      type = types.port;
      default = 13483;
      description = "service tcp port";
    };
    host = mkOption {
      type = types.str;
      description = "Host for web interface";
      default = "aldhy.ckie.dev";
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkService "aldhy" {
      home = cfg.folder;
      description = "aldhy distributed nix evaluator";
      script = ''
        ${mkCgi (mkRequiresScript ./web.sh) cfg.port} &
        ${mkRequiresScript ./queuerun.sh} &
      '';
      path = [ config.nix.package ];
      secrets.env = {
        source = "./secrets/aldhy.env";
        dest = "/run/keys/aldhy.env";
        permissions = "0400";
      };
    })

    {
      systemd.services.aldhy = {
        serviceConfig = {
          Type = "forking";
          RemoveIPC = mkForce "false";
          ProtectHostname = mkForce "false";
          ProtectProc = mkForce "false";
          ProcSubset = mkForce "all";
          ReadWritePaths = [ "/nix/var/nix/daemon-socket" ];
          # HACK sed uses some disallowed syscalls, figure out which
          SystemCallFilter = mkForce [ ];
          RestrictAddressFamilies = mkForce [ ];
          EnvironmentFile = config.cookie.secrets.aldhy-env.dest;
        };
        environment.FAVICON = ./favicon.ico;
      };

      cookie.bindfs = {
        aldhy = {
          source = "/var/lib/aldhy";
          dest = "${config.cookie.user.home}/aldhy";
          overlay = false;
          args =
            "--create-for-user=aldhy --create-with-perms=0600 -u ckie -g users -p 0600,u+X";
          wantedBy = [ "aldhy.service" ];
        };
        aldhy-build-logs = {
          source = "/var/lib/aldhy/build-logs";
          overlay = true;
          args = "-p 0600,u+D -u aldhy -g aldhy";
        };
        aldhy-nf-secrets = {
          source = "${config.cookie.user.home}/git/nixfiles/secrets";
          dest = "/var/lib/aldhy/nixfiles/secrets";
          overlay = false;
          wantedBy = [ "aldhy.service" ];
          args = "-u aldhy -g aldhy -p 0660,u+D -o ro";
        };
        aldhy-nf-encrypted = {
          source = "${config.cookie.user.home}/git/nixfiles/encrypted";
          dest = "/var/lib/aldhy/nixfiles/encrypted";
          overlay = false;
          wantedBy = [ "aldhy.service" ];
          args = "-u aldhy -g aldhy -p 0660,u+D -o ro";
        };
      };

    }

    {
      cookie.services.nginx.enable = true;
      cookie.services.prometheus.nginx-vhosts = [ "aldhy" ];
      services.nginx.virtualHosts.${cfg.host} = {
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          extraConfig = ''
            access_log /var/log/nginx/aldhy.access.log;
          '';
        };
      };
    }
  ]);
}
