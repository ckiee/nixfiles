{ lib, config, pkgs, ... }:

let
  cfg = config.cookie.services.coredns;
  sources = import ../../../nix/sources.nix;
  hosts = "${sources.dns-hosts}/hosts";
in
with lib; {
  options.cookie.services.coredns = {
    enable = mkEnableOption "Enables CoreDNS service";
    addServer = mkEnableOption "Add this server to the nameserver list";
    openFirewall = mkEnableOption "Open the listening port in the firewall";
    prometheus = {
      enable = mkEnableOption "Add prometheus monitoring";
      port = mkOption {
        type = types.port;
        default = 47824;
      };
    };
  };

  imports = [
    ./cloudflared-dns.nix # TODO wait for nixpkgs PR merge
  ];

  config = mkIf cfg.enable {
    services.cloudflared-dns = {
      enable = true;
      listenAddress = "localhost:1483"; # very arbitrary port
    };

    systemd.services.coredns = {
      # depend on cloudflared-dns
      wants = [ "cloudflared-dns.service" ]; # soft requirement
      after = [ "cloudflared-dns.service" ]; # we want to run AFTER cloudflared has started
    };

    services.coredns = {
      enable = true;

      config =
        let
          prom =
            if cfg.prometheus.enable then
              "prometheus FIXME:${toString cfg.prometheus.port}"
            else
              "";
        in
        ''
          . {
            ${prom}
            hosts ${hosts} {
              fallthrough
            }
            # Cloudflare and Google
            forward . 127.0.0.1:1483
            log
            errors
            cache 120 # two minutes
          }

          atori {
             ${prom}
             file ${../../../ext/atori.zone}
          }

          # Resolve everything under the root localhost TLD to 127.0.0.1
          localhost {
            ${prom}
            template IN A  {
                answer "{{ .Name }} 0 IN A 127.0.0.1"
            }
          }
        '';
    };

    networking = {
      nameservers = mkIf cfg.addServer [ "127.0.0.1" ];
      firewall.allowedUDPPorts = mkIf cfg.openFirewall [ 53 ];
    };
  };
}
