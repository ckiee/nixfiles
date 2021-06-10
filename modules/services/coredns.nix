{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.coredns;
  sources = import ../../nix/sources.nix;
  hosts = "${sources.dns-hosts}/hosts";
in with lib; {
  options.cookie.services.coredns = {
    enable = mkEnableOption "Enables CoreDNS service";
    addServer = mkEnableOption "Add this server to the nameserver list";
    addr = mkOption {
      type = types.str;
      default = "127.0.0.1";
      example = "10.77.2.8";
    };
    prometheus = {
      enable = mkEnableOption "Add prometheus monitoring";
      port = mkOption {
        type = types.port;
        default = 47824;
      };
    };
  };

  config = mkIf cfg.enable {
    services.coredns = {
      enable = true;

      config = let
        prom = if cfg.prometheus.enable then
          "prometheus ${cfg.addr}:${toString cfg.prometheus.port}"
        else
          "";
      in ''
        . {
          bind ${cfg.addr}
          ${prom}
          hosts ${hosts} {
            fallthrough
          }
          # Cloudflare and Google
          forward . 1.1.1.1 1.0.0.1 8.8.8.8 8.8.4.4
          cache
        }

        # akua {
        #   bind ${cfg.addr}
        #   ${prom}
        #   file $ {./akua.zone}
        # }

        localhost {
          bind ${cfg.addr}
          ${prom}
          template IN A  {
              answer "{{ .Name }} 0 IN A 127.0.0.1"
          }
        }
      '';
    };

    networking = mkIf cfg.addServer { nameservers = [ cfg.addr ]; };
  };
}
